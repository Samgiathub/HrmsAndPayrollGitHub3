using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040DepartmentMaster
{
    public decimal DeptId { get; set; }

    public decimal CmpId { get; set; }

    public string DeptName { get; set; } = null!;

    public decimal DeptDisNo { get; set; }

    public string? DeptCode { get; set; }

    public byte? IsActive { get; set; }

    public DateTime? InActiveEffeDate { get; set; }

    public byte? OjtApplicable { get; set; }

    public decimal? MinimumWages { get; set; }

    public byte? Category { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0040HrDocMaster> T0040HrDocMasters { get; set; } = new List<T0040HrDocMaster>();

    public virtual ICollection<T0040TrainingInductionMaster> T0040TrainingInductionMasters { get; set; } = new List<T0040TrainingInductionMaster>();

    public virtual ICollection<T0050AppraisalUtilitySetting> T0050AppraisalUtilitySettings { get; set; } = new List<T0050AppraisalUtilitySetting>();

    public virtual ICollection<T0050HrmsAppraisalSetting> T0050HrmsAppraisalSettings { get; set; } = new List<T0050HrmsAppraisalSetting>();

    public virtual ICollection<T0050HrmsRangeDeptAllocation> T0050HrmsRangeDeptAllocations { get; set; } = new List<T0050HrmsRangeDeptAllocation>();

    public virtual ICollection<T0050HrmsRecruitmentRequest> T0050HrmsRecruitmentRequests { get; set; } = new List<T0050HrmsRecruitmentRequest>();

    public virtual ICollection<T0050HrmsSkillRateSetting> T0050HrmsSkillRateSettings { get; set; } = new List<T0050HrmsSkillRateSetting>();

    public virtual ICollection<T0052HrmsRecruitmentRequestApproval> T0052HrmsRecruitmentRequestApprovals { get; set; } = new List<T0052HrmsRecruitmentRequestApproval>();

    public virtual ICollection<T0052IncrementUtility> T0052IncrementUtilities { get; set; } = new List<T0052IncrementUtility>();

    public virtual ICollection<T0052ResumeFinalApproval> T0052ResumeFinalApprovals { get; set; } = new List<T0052ResumeFinalApproval>();

    public virtual ICollection<T0055SkillGeneralSetting> T0055SkillGeneralSettings { get; set; } = new List<T0055SkillGeneralSetting>();

    public virtual ICollection<T0060ResumeFinal> T0060ResumeFinals { get; set; } = new List<T0060ResumeFinal>();

    public virtual ICollection<T0080EmpMaster> T0080EmpMasters { get; set; } = new List<T0080EmpMaster>();

    public virtual ICollection<T0090AppMaster> T0090AppMasters { get; set; } = new List<T0090AppMaster>();

    public virtual ICollection<T0130HrmsTrainingAlert> T0130HrmsTrainingAlerts { get; set; } = new List<T0130HrmsTrainingAlert>();
}
