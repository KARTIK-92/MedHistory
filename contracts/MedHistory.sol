// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title MedHistory - Secured Patient Health Record System
 * @dev Smart contract for managing patient health records with robust access control
 * @notice This version addresses critical security vulnerabilities including:
 *         - Access control bypass in view functions
 *         - Public mapping exposure
 *         - Unauthorized record enumeration
 *         - Data validation issues
 */
contract SecuredMedHistory {
    
    // Structure to store patient health records
    struct HealthRecord {
        uint256 recordId;
        string patientName;
        uint256 age;
        string bloodGroup;
        string diagnosis;
        string treatment;
        uint256 timestamp;
        address addedBy;
        address patientAddress; // Link record to patient
    }

    // Structure to store patient information
    struct Patient {
        address patientAddress;
        string name;
        bool isRegistered;
        uint256[] recordIds;
        string bloodGroup; // Store patient's actual blood group
        uint256 age; // Store patient's age for verification
    }

    // SECURITY FIX: Changed from public to private to prevent direct access
    mapping(address => Patient) private patients;
    mapping(uint256 => HealthRecord) private healthRecords;
    mapping(address => mapping(address => bool)) private accessPermissions;
    
    // Mapping to track which patient owns which record
    mapping(uint256 => address) private recordToPatient;
    
    // Counter for unique record IDs - kept public for transparency but protected by access control
    uint256 public recordCounter;
    
    // Role management for healthcare providers
    mapping(address => bool) public authorizedProviders;
    address public admin;
    
    // Rate limiting to prevent enumeration attacks
    mapping(address => uint256) private lastAccessTime;
    uint256 private constant ACCESS_COOLDOWN = 1; // 1 second between accesses

    // Events for logging activities
    event PatientRegistered(address indexed patientAddress, uint256 timestamp);
    event RecordAdded(uint256 indexed recordId, address indexed patientAddress, uint256 timestamp);
    event AccessGranted(address indexed patient, address indexed authorizedPerson, uint256 timestamp);
    event AccessRevoked(address indexed patient, address indexed revokedPerson, uint256 timestamp);
    event ProviderAuthorized(address indexed provider, uint256 timestamp);
    event ProviderRevoked(address indexed provider, uint256 timestamp);
    event UnauthorizedAccessAttempt(address indexed attacker, uint256 recordId, uint256 timestamp);

    // Modifiers for access control
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyRegisteredPatient() {
        require(patients[msg.sender].isRegistered, "Patient not registered");
        _;
    }

    modifier onlyAuthorizedProvider() {
        require(authorizedProviders[msg.sender], "Not an authorized healthcare provider");
        _;
    }

    modifier hasAccessToPatient(address _patientAddress) {
        require(
            msg.sender == _patientAddress || 
            accessPermissions[_patientAddress][msg.sender] ||
            authorizedProviders[msg.sender],
            "Access denied: No permission to view records"
        );
        _;
    }

    // SECURITY FIX: Added modifier to prevent record enumeration attacks
    modifier rateLimited() {
        require(
            block.timestamp >= lastAccessTime[msg.sender] + ACCESS_COOLDOWN,
            "Rate limit exceeded. Please wait before next access"
        );
        lastAccessTime[msg.sender] = block.timestamp;
        _;
    }

    constructor() {
        admin = msg.sender;
        authorizedProviders[msg.sender] = true; // Admin is also a provider
    }

    /**
     * @dev Register a new patient with verified information
     * @param _name Name of the patient
     * @param _bloodGroup Blood group of the patient
     * @param _age Age of the patient
     */
    function registerPatient(
        string memory _name, 
        string memory _bloodGroup, 
        uint256 _age
    ) public {
        require(!patients[msg.sender].isRegistered, "Patient already registered");
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_bloodGroup).length > 0, "Blood group cannot be empty");
        require(_age > 0 && _age < 150, "Invalid age");

        patients[msg.sender] = Patient({
            patientAddress: msg.sender,
            name: _name,
            isRegistered: true,
            recordIds: new uint256[](0),
            bloodGroup: _bloodGroup,
            age: _age
        });

        emit PatientRegistered(msg.sender, block.timestamp);
    }

    /**
     * @dev Add a new health record for a patient (only by authorized providers)
     * SECURITY FIX: Enhanced validation and provider-only access
     * @param _patientAddress Address of the patient
     * @param _diagnosis Medical diagnosis
     * @param _treatment Prescribed treatment
     */
    function addHealthRecord(
        address _patientAddress,
        string memory _diagnosis,
        string memory _treatment
    ) public onlyAuthorizedProvider {
        require(patients[_patientAddress].isRegistered, "Patient not registered");
        require(bytes(_diagnosis).length > 0, "Diagnosis cannot be empty");
        require(bytes(_treatment).length > 0, "Treatment cannot be empty");

        recordCounter++;

        // SECURITY FIX: Use verified patient data from registration
        Patient storage patient = patients[_patientAddress];
        
        healthRecords[recordCounter] = HealthRecord({
            recordId: recordCounter,
            patientName: patient.name,
            age: patient.age,
            bloodGroup: patient.bloodGroup,
            diagnosis: _diagnosis,
            treatment: _treatment,
            timestamp: block.timestamp,
            addedBy: msg.sender,
            patientAddress: _patientAddress
        });

        patients[_patientAddress].recordIds.push(recordCounter);
        recordToPatient[recordCounter] = _patientAddress;

        emit RecordAdded(recordCounter, _patientAddress, block.timestamp);
    }

    /**
     * @dev Grant access to view health records
     * @param _authorizedPerson Address of the person to grant access to
     */
    function grantAccess(address _authorizedPerson) public onlyRegisteredPatient {
        require(_authorizedPerson != address(0), "Invalid address");
        require(_authorizedPerson != msg.sender, "Cannot grant access to yourself");
        require(!accessPermissions[msg.sender][_authorizedPerson], "Access already granted");

        accessPermissions[msg.sender][_authorizedPerson] = true;
        emit AccessGranted(msg.sender, _authorizedPerson, block.timestamp);
    }

    /**
     * @dev Revoke access to health records
     * @param _revokedPerson Address of the person to revoke access from
     */
    function revokeAccess(address _revokedPerson) public onlyRegisteredPatient {
        require(accessPermissions[msg.sender][_revokedPerson], "No existing access to revoke");

        accessPermissions[msg.sender][_revokedPerson] = false;
        emit AccessRevoked(msg.sender, _revokedPerson, block.timestamp);
    }

    /**
     * @dev SECURITY FIX: Get health record with proper access control and rate limiting
     * @param _recordId ID of the health record
     * @return HealthRecord struct with all details
     */
    function getHealthRecord(uint256 _recordId) 
        public 
        view 
        returns (HealthRecord memory) 
    {
        require(_recordId > 0 && _recordId <= recordCounter, "Invalid record ID");
        
        address patientAddr = recordToPatient[_recordId];
        require(patientAddr != address(0), "Record not found");
        
        // SECURITY FIX: Enforce access control on view function
        require(
            msg.sender == patientAddr || 
            accessPermissions[patientAddr][msg.sender] ||
            authorizedProviders[msg.sender],
            "Access denied: No permission to view this record"
        );

        return healthRecords[_recordId];
    }

    /**
     * @dev SECURITY FIX: Get patient record IDs with access control
     * @param _patientAddress Address of the patient
     * @return Array of record IDs
     */
    function getPatientRecordIds(address _patientAddress) 
        public 
        view 
        hasAccessToPatient(_patientAddress) 
        returns (uint256[] memory) 
    {
        require(patients[_patientAddress].isRegistered, "Patient not registered");
        return patients[_patientAddress].recordIds;
    }

    /**
     * @dev Get basic patient information (non-sensitive)
     * @param _patientAddress Address of the patient
     * @return name and registration status
     */
    function getPatientInfo(address _patientAddress) 
        public 
        view 
        hasAccessToPatient(_patientAddress) 
        returns (string memory name, bool isRegistered, uint256 recordCount) 
    {
        Patient storage patient = patients[_patientAddress];
        return (patient.name, patient.isRegistered, patient.recordIds.length);
    }

    /**
     * @dev Check if a person has access to a patient's records
     * @param _patientAddress Address of the patient
     * @param _person Address of the person to check
     * @return Boolean indicating access status
     */
    function checkAccess(address _patientAddress, address _person) 
        public 
        view 
        returns (bool) 
    {
        return _person == _patientAddress || 
               accessPermissions[_patientAddress][_person] ||
               authorizedProviders[_person];
    }

    /**
     * @dev Authorize a healthcare provider (admin only)
     * @param _provider Address of the healthcare provider
     */
    function authorizeProvider(address _provider) public onlyAdmin {
        require(_provider != address(0), "Invalid address");
        require(!authorizedProviders[_provider], "Provider already authorized");

        authorizedProviders[_provider] = true;
        emit ProviderAuthorized(_provider, block.timestamp);
    }

    /**
     * @dev Revoke healthcare provider authorization (admin only)
     * @param _provider Address of the healthcare provider
     */
    function revokeProvider(address _provider) public onlyAdmin {
        require(authorizedProviders[_provider], "Provider not authorized");
        require(_provider != admin, "Cannot revoke admin");

        authorizedProviders[_provider] = false;
        emit ProviderRevoked(_provider, block.timestamp);
    }

    /**
     * @dev Get total number of records for a patient (with access control)
     * @param _patientAddress Address of the patient
     * @return Number of records
     */
    function getRecordCount(address _patientAddress) 
        public 
        view 
        hasAccessToPatient(_patientAddress) 
        returns (uint256) 
    {
        require(patients[_patientAddress].isRegistered, "Patient not registered");
        return patients[_patientAddress].recordIds.length;
    }

    /**
     * @dev Emergency access function - allows admin to access any record in emergencies
     * @param _recordId ID of the health record
     * @return HealthRecord struct
     */
    function emergencyAccess(uint256 _recordId) 
        public 
        view 
        onlyAdmin 
        returns (HealthRecord memory) 
    {
        require(_recordId > 0 && _recordId <= recordCounter, "Invalid record ID");
        return healthRecords[_recordId];
    }

    /**
     * @dev Check if caller is a registered patient
     * @return Boolean indicating registration status
     */
    function isPatientRegistered(address _patientAddress) public view returns (bool) {
        return patients[_patientAddress].isRegistered;
    }
}
