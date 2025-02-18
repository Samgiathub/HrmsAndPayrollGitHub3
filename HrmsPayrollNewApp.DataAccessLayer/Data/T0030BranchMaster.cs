using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0030BranchMaster
{
    public decimal BranchId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? StateId { get; set; }

    public string? BranchCode { get; set; }

    public string? BranchName { get; set; }

    public string? BranchCity { get; set; }

    public string? BranchAddress { get; set; }

    public decimal? BranchDefault { get; set; }

    public string? CompName { get; set; }

    public byte IsContractorBranch { get; set; }

    public decimal? LocationId { get; set; }

    public string? PtRcNo { get; set; }

    public string? PtZone { get; set; }

    public string? PtWardNo { get; set; }

    public string? PtCensusNo { get; set; }

    public byte? IsActive { get; set; }

    public DateTime? InActiveEffeDate { get; set; }

    public string? PfNo { get; set; }

    public string? EsicNo { get; set; }

    public int? DistrictId { get; set; }

    public int? TehsilId { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0020StateMaster? State { get; set; }

    public virtual ICollection<T0011Login> T0011Logins { get; set; } = new List<T0011Login>();

    public virtual ICollection<T0015LoginBranchRight> T0015LoginBranchRights { get; set; } = new List<T0015LoginBranchRight>();

    public virtual ICollection<T0035ContractorDetailMaster> T0035ContractorDetailMasters { get; set; } = new List<T0035ContractorDetailMaster>();

    public virtual ICollection<T0040EmployeeRating> T0040EmployeeRatings { get; set; } = new List<T0040EmployeeRating>();

    public virtual ICollection<T0040HolidayMaster> T0040HolidayMasters { get; set; } = new List<T0040HolidayMaster>();

    public virtual ICollection<T0040HrDocMaster> T0040HrDocMasters { get; set; } = new List<T0040HrDocMaster>();

    public virtual ICollection<T0040IpMaster> T0040IpMasters { get; set; } = new List<T0040IpMaster>();

    public virtual ICollection<T0040ProfessionalSetting> T0040ProfessionalSettings { get; set; } = new List<T0040ProfessionalSetting>();

    public virtual ICollection<T0040SmsSetting> T0040SmsSettings { get; set; } = new List<T0040SmsSetting>();

    public virtual ICollection<T0040WeekoffMaster> T0040WeekoffMasters { get; set; } = new List<T0040WeekoffMaster>();

    public virtual ICollection<T0050AppraisalUtilitySetting> T0050AppraisalUtilitySettings { get; set; } = new List<T0050AppraisalUtilitySetting>();

    public virtual ICollection<T0050HrmsAppraisalSetting> T0050HrmsAppraisalSettings { get; set; } = new List<T0050HrmsAppraisalSetting>();

    public virtual ICollection<T0050HrmsRecruitmentRequest> T0050HrmsRecruitmentRequests { get; set; } = new List<T0050HrmsRecruitmentRequest>();

    public virtual ICollection<T0050HrmsSkillRateSetting> T0050HrmsSkillRateSettings { get; set; } = new List<T0050HrmsSkillRateSetting>();

    public virtual ICollection<T0050OptionalHolidayLimit> T0050OptionalHolidayLimits { get; set; } = new List<T0050OptionalHolidayLimit>();

    public virtual ICollection<T0050SubBranch> T0050SubBranches { get; set; } = new List<T0050SubBranch>();

    public virtual ICollection<T0052HrmsRecruitmentRequestApproval> T0052HrmsRecruitmentRequestApprovals { get; set; } = new List<T0052HrmsRecruitmentRequestApproval>();

    public virtual ICollection<T0052IncrementUtility> T0052IncrementUtilities { get; set; } = new List<T0052IncrementUtility>();

    public virtual ICollection<T0052ResumeFinalApproval> T0052ResumeFinalApprovals { get; set; } = new List<T0052ResumeFinalApproval>();

    public virtual ICollection<T0055SkillGeneralSetting> T0055SkillGeneralSettings { get; set; } = new List<T0055SkillGeneralSetting>();

    public virtual ICollection<T0060ResumeFinal> T0060ResumeFinals { get; set; } = new List<T0060ResumeFinal>();

    public virtual ICollection<T0080EmpMaster> T0080EmpMasters { get; set; } = new List<T0080EmpMaster>();

    public virtual ICollection<T0090AppMaster> T0090AppMasters { get; set; } = new List<T0090AppMaster>();

    public virtual ICollection<T0090HrmsAppraisalInitiation> T0090HrmsAppraisalInitiations { get; set; } = new List<T0090HrmsAppraisalInitiation>();

    public virtual ICollection<T0100AdGradeBranchWise> T0100AdGradeBranchWises { get; set; } = new List<T0100AdGradeBranchWise>();

    public virtual ICollection<T0220EsicChallanSett> T0220EsicChallanSetts { get; set; } = new List<T0220EsicChallanSett>();

    public virtual ICollection<T0220EsicChallan> T0220EsicChallans { get; set; } = new List<T0220EsicChallan>();

    public virtual ICollection<T0220PfChallanSett> T0220PfChallanSetts { get; set; } = new List<T0220PfChallanSett>();

    public virtual ICollection<T0220PfChallan> T0220PfChallans { get; set; } = new List<T0220PfChallan>();
}
