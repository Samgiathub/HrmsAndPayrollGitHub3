using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040GradeMaster
{
    public decimal GrdId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? CatId { get; set; }

    public string GrdName { get; set; } = null!;

    public string GrdDescription { get; set; } = null!;

    public decimal GrdDisNo { get; set; }

    public decimal ShortFallDays { get; set; }

    public decimal ShortFallWDays { get; set; }

    public decimal? BasicPercentage { get; set; }

    public string? BasicCalcOn { get; set; }

    public decimal MinBasic { get; set; }

    public decimal? GrdBasicFrom { get; set; }

    public decimal? GrdBasicTo { get; set; }

    public decimal? EligibilityAmount { get; set; }

    public string? Signature { get; set; }

    public byte EligibilityDesignationwise { get; set; }

    public byte OtApplicable { get; set; }

    public byte? IsActive { get; set; }

    public DateTime? InActiveEffeDate { get; set; }

    public decimal FixBasicSalary { get; set; }

    public decimal FixBasicSalaryNight { get; set; }

    public string? DesigId { get; set; }

    public byte IsGradewiseSalary { get; set; }

    public string? GrdWagesType { get; set; }

    public virtual T0030CategoryMaster? Cat { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0040HrDocMaster> T0040HrDocMasters { get; set; } = new List<T0040HrDocMaster>();

    public virtual ICollection<T0041ClaimMaxlimitGradeDesigCityWise> T0041ClaimMaxlimitGradeDesigCityWises { get; set; } = new List<T0041ClaimMaxlimitGradeDesigCityWise>();

    public virtual ICollection<T0050AppraisalUtilitySetting> T0050AppraisalUtilitySettings { get; set; } = new List<T0050AppraisalUtilitySetting>();

    public virtual ICollection<T0050HrmsAppraisalSetting> T0050HrmsAppraisalSettings { get; set; } = new List<T0050HrmsAppraisalSetting>();

    public virtual ICollection<T0050HrmsRecruitmentRequest> T0050HrmsRecruitmentRequests { get; set; } = new List<T0050HrmsRecruitmentRequest>();

    public virtual ICollection<T0050HrmsSkillRateSetting> T0050HrmsSkillRateSettings { get; set; } = new List<T0050HrmsSkillRateSetting>();

    public virtual ICollection<T0050LeaveDetail> T0050LeaveDetails { get; set; } = new List<T0050LeaveDetail>();

    public virtual ICollection<T0052HrmsRecruitmentRequestApproval> T0052HrmsRecruitmentRequestApprovals { get; set; } = new List<T0052HrmsRecruitmentRequestApproval>();

    public virtual ICollection<T0052IncrementUtility> T0052IncrementUtilities { get; set; } = new List<T0052IncrementUtility>();

    public virtual ICollection<T0052ResumeFinalApproval> T0052ResumeFinalApprovals { get; set; } = new List<T0052ResumeFinalApproval>();

    public virtual ICollection<T0055SkillGeneralSetting> T0055SkillGeneralSettings { get; set; } = new List<T0055SkillGeneralSetting>();

    public virtual ICollection<T0060ResumeFinal> T0060ResumeFinals { get; set; } = new List<T0060ResumeFinal>();

    public virtual ICollection<T0080EmpMaster> T0080EmpMasters { get; set; } = new List<T0080EmpMaster>();

    public virtual ICollection<T0090AppMaster> T0090AppMasters { get; set; } = new List<T0090AppMaster>();

    public virtual ICollection<T0095LeaveOpening> T0095LeaveOpenings { get; set; } = new List<T0095LeaveOpening>();

    public virtual ICollection<T0100AdGradeBranchWise> T0100AdGradeBranchWises { get; set; } = new List<T0100AdGradeBranchWise>();

    public virtual ICollection<T0100ArApplication> T0100ArApplications { get; set; } = new List<T0100ArApplication>();

    public virtual ICollection<T0120GradewiseAllowance> T0120GradewiseAllowances { get; set; } = new List<T0120GradewiseAllowance>();
}
