using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0055ResumeMaster
{
    public decimal ResumeId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? RecPostId { get; set; }

    public DateTime? ResumePostedDate { get; set; }

    public string? Initial { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public string? EmpSecondName { get; set; }

    public string EmpLastName { get; set; } = null!;

    public DateTime DateOfBirth { get; set; }

    public string? MaritalStatus { get; set; }

    public string? Gender { get; set; }

    public string? PresentStreet { get; set; }

    public string? PresentCity { get; set; }

    public string? PresentState { get; set; }

    public string? PresentPostBox { get; set; }

    public string? PermanentStreet { get; set; }

    public string? PermanentCity { get; set; }

    public string? PermanentState { get; set; }

    public string? PermanenttPostBox { get; set; }

    public string? HomeTelNo { get; set; }

    public string? MobileNo { get; set; }

    public string? PrimaryEmail { get; set; }

    public string? OtherEmail { get; set; }

    public string? NonTechnicalSkill { get; set; }

    public decimal? CurCtc { get; set; }

    public decimal? ExpCtc { get; set; }

    public decimal? TotalExp { get; set; }

    public string? ResumeName { get; set; }

    public string? FileName { get; set; }

    public byte? ResumeStatus { get; set; }

    public decimal? FinalCtc { get; set; }

    public DateTime? DateOfJoin { get; set; }

    public decimal? BasicSalary { get; set; }

    public decimal? EmpFullPf { get; set; }

    public decimal? EmpFixSalary { get; set; }

    public decimal? PresentLoc { get; set; }

    public decimal? PermanentLocId { get; set; }

    public DateTime? SystemDate { get; set; }

    public string? ResumeCode { get; set; }

    public int? HasPancard { get; set; }

    public string? PanCardNo { get; set; }

    public string? PanCardAckPath { get; set; }

    public string? AddressProof { get; set; }

    public int? ConfirmJoining { get; set; }

    public string? Comments { get; set; }

    public string? FatherName { get; set; }

    public int? Lock { get; set; }

    public string? IdentityProof { get; set; }

    public string? PresentDistrict { get; set; }

    public string? PresentPo { get; set; }

    public string? PermanentDistrict { get; set; }

    public string? PermanentPo { get; set; }

    public int? DocumentTypeIdentity { get; set; }

    public string? PanCardProof { get; set; }

    public string? PanCardAckNo { get; set; }

    public int? DocumentTypeAddressProof { get; set; }

    public int? DocumentTypeIdentity2 { get; set; }

    public string? IdentityProof2 { get; set; }

    public int? DocumentTypeAddressProof2 { get; set; }

    public string? AddressProof2 { get; set; }

    public int? DocumentTypeMarriageProof { get; set; }

    public string? MarriageProof { get; set; }

    public decimal? SourceTypeId { get; set; }

    public decimal? SourceId { get; set; }

    public DateTime? MarriageDate { get; set; }

    public int? ResumeScreeningStatus { get; set; }

    public decimal? ResumeScreeningBy { get; set; }

    public int? Archive { get; set; }

    public byte IsPhysical { get; set; }

    public string? SourceName { get; set; }

    public string? AadharCardNo { get; set; }

    public string? AadharCardPath { get; set; }

    public decimal? StateDomicile { get; set; }

    public string? PlaceofBirth { get; set; }

    public string? TrainingSeminars { get; set; }

    public string? JobProfile { get; set; }

    public string? LocationPreference { get; set; }

    public string? ResponseOfCandidate { get; set; }

    public string ResponseComments { get; set; } = null!;

    public decimal? TransferCmpId { get; set; }

    public decimal? TransferRecPostId { get; set; }

    public decimal? TransferLocationId { get; set; }

    public decimal? TransferResumeId { get; set; }

    public string Religion { get; set; } = null!;

    public string Caste { get; set; } = null!;

    public string CasteCategory { get; set; } = null!;

    public int? NoOfChildren { get; set; }

    public string ShirtSize { get; set; } = null!;

    public string PantSize { get; set; } = null!;

    public string ShoeSize { get; set; } = null!;

    public byte? IsPhysicalDisable { get; set; }

    public double? PhysicalDisablePerc { get; set; }

    public string? VideoResume { get; set; }

    public string Nationality { get; set; } = null!;

    public string MotherTongue { get; set; } = null!;

    public virtual T0001LocationMaster? PermanentLoc { get; set; }

    public virtual T0001LocationMaster? PresentLocNavigation { get; set; }

    public virtual ICollection<T0052ResumeFinalApproval> T0052ResumeFinalApprovals { get; set; } = new List<T0052ResumeFinalApproval>();

    public virtual ICollection<T0055HrmsInterviewScheduleHistory> T0055HrmsInterviewScheduleHistories { get; set; } = new List<T0055HrmsInterviewScheduleHistory>();

    public virtual ICollection<T0055HrmsInterviewSchedule> T0055HrmsInterviewSchedules { get; set; } = new List<T0055HrmsInterviewSchedule>();

    public virtual ICollection<T0060ResumeFinal> T0060ResumeFinals { get; set; } = new List<T0060ResumeFinal>();

    public virtual ICollection<T0090AppMaster> T0090AppMasters { get; set; } = new List<T0090AppMaster>();

    public virtual ICollection<T0090HrmsAssetAllocation> T0090HrmsAssetAllocations { get; set; } = new List<T0090HrmsAssetAllocation>();

    public virtual ICollection<T0090HrmsAssetInstallationDetail> T0090HrmsAssetInstallationDetails { get; set; } = new List<T0090HrmsAssetInstallationDetail>();

    public virtual ICollection<T0090HrmsResumeBank> T0090HrmsResumeBanks { get; set; } = new List<T0090HrmsResumeBank>();

    public virtual ICollection<T0090HrmsResumeDocument> T0090HrmsResumeDocuments { get; set; } = new List<T0090HrmsResumeDocument>();

    public virtual ICollection<T0090HrmsResumeEarnDeduction> T0090HrmsResumeEarnDeductions { get; set; } = new List<T0090HrmsResumeEarnDeduction>();

    public virtual ICollection<T0090HrmsResumeExperience> T0090HrmsResumeExperiences { get; set; } = new List<T0090HrmsResumeExperience>();

    public virtual ICollection<T0090HrmsResumeHealth> T0090HrmsResumeHealths { get; set; } = new List<T0090HrmsResumeHealth>();

    public virtual ICollection<T0090HrmsResumeImmigration> T0090HrmsResumeImmigrations { get; set; } = new List<T0090HrmsResumeImmigration>();

    public virtual ICollection<T0090HrmsResumeNominee> T0090HrmsResumeNominees { get; set; } = new List<T0090HrmsResumeNominee>();

    public virtual ICollection<T0090HrmsResumeQualification> T0090HrmsResumeQualifications { get; set; } = new List<T0090HrmsResumeQualification>();

    public virtual ICollection<T0090HrmsResumeSkill> T0090HrmsResumeSkills { get; set; } = new List<T0090HrmsResumeSkill>();

    public virtual ICollection<T0095HrmsCandidateScheme> T0095HrmsCandidateSchemes { get; set; } = new List<T0095HrmsCandidateScheme>();

    public virtual ICollection<T0100HrmsResumeEarnDeductionLevel> T0100HrmsResumeEarnDeductionLevels { get; set; } = new List<T0100HrmsResumeEarnDeductionLevel>();
}
