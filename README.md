# MedHistory – Patient Health Record System

## Project Description

MedHistory is a blockchain-based decentralized application (DApp) built on Ethereum that revolutionizes the management of patient health records. This smart contract system provides a secure, transparent, and patient-centric approach to storing and sharing medical information. By leveraging blockchain technology, MedHistory ensures data immutability, eliminates single points of failure, and gives patients complete control over who can access their sensitive medical information.

The system implements role-based access control mechanisms where patients can grant or revoke access to healthcare providers, ensuring compliance with healthcare data protection regulations while maintaining the privacy and security of medical records.

## Project Vision

Our vision is to create a decentralized healthcare ecosystem where:

- *Patient Empowerment*: Patients have complete ownership and control over their medical records
- *Interoperability*: Healthcare providers can seamlessly access patient history with proper authorization, improving treatment outcomes
- *Data Security*: Medical records are stored immutably on the blockchain, protecting against unauthorized modifications and data breaches
- *Emergency Access*: Authorized medical professionals can quickly access critical patient information during emergencies
- *Transparency*: All access and modifications to health records are logged and auditable
- *Global Accessibility*: Patients can access their medical history from anywhere in the world, eliminating geographical barriers

MedHistory aims to bridge the gap between traditional healthcare systems and modern blockchain technology, creating a more efficient, secure, and patient-focused healthcare infrastructure.

## Key Features

### 1. Patient Registration
- Secure registration system for patients using their Ethereum wallet address
- One-time registration process with unique patient identification
- Prevents duplicate registrations for the same address

### 2. Health Record Management
- Comprehensive health record storage including patient name, age, blood group, diagnosis, and treatment
- Timestamped records with information about who added the record
- Unique record IDs for easy retrieval and reference
- Supports multiple records per patient for complete medical history

### 3. Access Control System
- Patient-controlled permission system for sharing medical records
- Grant access to doctors, healthcare providers, or family members
- Revoke access at any time to maintain privacy
- View-only access for authorized persons to prevent unauthorized modifications
- Built-in checks to prevent self-access grants and invalid addresses

### 4. Data Retrieval Functions
- Retrieve all record IDs associated with a patient
- Fetch detailed information for specific health records
- Check access permissions for any address
- Secure data access with permission validation

### 5. Event Logging
- All major actions emit events for transparency and auditability
- Track patient registrations, record additions, and access changes
- Enables off-chain monitoring and notification systems

### 6. Security Features
- Modifier-based access control to prevent unauthorized access
- Input validation to ensure data integrity
- Address verification to prevent malicious activities
- Immutable record storage ensuring data cannot be tampered with

## Future Scope

### Short-term Enhancements
1. *IPFS Integration*: Store large medical files (X-rays, MRI scans, lab reports) on IPFS and store only hashes on-chain to reduce gas costs
2. *Emergency Access Protocol*: Implement break-glass access for emergency medical situations with audit trails
3. *Multi-signature Authorization*: Require multiple parties to approve sensitive record modifications
4. *Role-based Access Levels*: Define different access levels (view-only, add records, full access) for various healthcare providers

### Mid-term Developments
5. *Doctor/Healthcare Provider Registry*: Create a separate registry for verified healthcare providers
6. *Prescription Management*: Add functionality for doctors to issue digital prescriptions linked to patient records
7. *Insurance Integration*: Smart contracts to automate insurance claims processing based on medical records
8. *Appointment Scheduling*: Integrate scheduling system linked to patient records
9. *Consent Management*: Advanced consent mechanisms compliant with GDPR and HIPAA regulations

### Long-term Vision
10. *Interoperability with EHR Systems*: Bridge connections with existing Electronic Health Record systems
11. *AI-powered Analytics*: Integrate machine learning models for predictive healthcare analytics while maintaining privacy
12. *Cross-chain Compatibility*: Support multiple blockchain networks for wider adoption
13. *Telemedicine Integration*: Connect with telemedicine platforms for remote consultations with automatic record updates
14. *Pharmaceutical Supply Chain*: Track medication authenticity and delivery using blockchain
15. *Research Data Sharing*: Anonymous data sharing protocols for medical research with patient consent
16. *Mobile Application*: User-friendly mobile apps for patients and healthcare providers
17. *IoT Device Integration*: Automatic health record updates from wearable devices and medical IoT equipment

### Technical Improvements
- Gas optimization for cost-effective transactions
- Layer 2 scaling solutions for higher throughput
- Enhanced encryption mechanisms for sensitive data
- Biometric authentication integration
- Zero-knowledge proofs for privacy-preserving verification

## Getting Started

### Prerequisites
- Node.js and npm installed
- Truffle or Hardhat framework
- MetaMask or any Ethereum wallet
- Ganache for local blockchain testing (optional)

### Installation
1. Clone the repository
2. Install dependencies: npm install
3. Compile the smart contract: truffle compile or npx hardhat compile
4. Deploy to local network: truffle migrate or npx hardhat run scripts/deploy.js
5. Interact with the contract using Truffle console or build a frontend interface

### Usage
1. *Register as Patient*: Call registerPatient() with your name
2. *Add Health Records*: Use addHealthRecord() to add medical information
3. *Grant Access*: Use grantAccess() to allow doctors/family members to view your records
4. *View Records*: Authorized users can retrieve records using getPatientRecordIds() and getHealthRecord()
5. *Revoke Access*: Use revokeAccess() to remove permissions

## Smart Contract Details
- *Solidity Version*: ^0.8.0
- *License*: MIT
- *Contract Name*: Project
- *Core Functions*: 3 main functions (registerPatient, addHealthRecord, grantAccess) + additional utility functions

## Security Considerations
- Always use the contract with proper access controls
- Verify addresses before granting access
- Regularly audit access permissions
- Use secure wallet practices for managing patient addresses
- Consider encryption for sensitive data before storing on-chain

## Contributing
Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

## License
This project is licensed under the MIT License.

## Contact
For questions or support, please open an issue in the repository.

---

*Disclaimer*: This smart contract is for educational and demonstration purposes. Before deploying to production, conduct thorough security audits and ensure compliance with healthcare regulations in your jurisdiction.
