pragma solidity ^0.8.4;

error IncorrectlySignedDataSourceRequest(address sender);
error DataSourceAlreadyExists();
error InvalidStakeAmount();
error InsufficientAmount(uint amount);
error JobNotActive();
error JobNotAcceptingApplications();
error UnauthorizedCloser();
error LockTimeExceeded();
error RawDataNotStored();
error InvalidValidationFees();
error WithdrawlAmountExceedsBalance(uint balance);
error SkillVerificationFailed();
error InvalidConditionForCreatingSkills();
error SkillMintVerificationFailed();