using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040DesignationMaster
{
    public decimal DesigId { get; set; }

    public decimal CmpId { get; set; }

    public string DesigName { get; set; } = null!;

    public decimal DesigDisNo { get; set; }

    public decimal? DefId { get; set; }

    public decimal? ParentId { get; set; }

    public byte? IsMain { get; set; }

    public string? ModeOfTravel { get; set; }

    public decimal OptionalAllowPer { get; set; }

    public string? DesigCode { get; set; }

    public byte? IsActive { get; set; }

    public DateTime? InActiveEffeDate { get; set; }

    public byte AbscondingReminder { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0010HrCompReq> T0010HrCompReqs { get; set; } = new List<T0010HrCompReq>();

    public virtual ICollection<T0040HrDocMaster> T0040HrDocMasters { get; set; } = new List<T0040HrDocMaster>();

    public virtual ICollection<T0041ClaimMaxlimitDesign> T0041ClaimMaxlimitDesigns { get; set; } = new List<T0041ClaimMaxlimitDesign>();

    public virtual ICollection<T0041ClaimMaxlimitGradeDesigCityWise> T0041ClaimMaxlimitGradeDesigCityWises { get; set; } = new List<T0041ClaimMaxlimitGradeDesigCityWise>();

    public virtual ICollection<T0041VehicleMaxlimitDesign> T0041VehicleMaxlimitDesigns { get; set; } = new List<T0041VehicleMaxlimitDesign>();

    public virtual ICollection<T0050AdExpenseLimit> T0050AdExpenseLimits { get; set; } = new List<T0050AdExpenseLimit>();

    public virtual ICollection<T0050AppraisalUtilitySetting> T0050AppraisalUtilitySettings { get; set; } = new List<T0050AppraisalUtilitySetting>();

    public virtual ICollection<T0050HrmsAppraisalSetting> T0050HrmsAppraisalSettings { get; set; } = new List<T0050HrmsAppraisalSetting>();

    public virtual ICollection<T0050HrmsRecruitmentRequest> T0050HrmsRecruitmentRequests { get; set; } = new List<T0050HrmsRecruitmentRequest>();

    public virtual ICollection<T0050HrmsSkillRateSetting> T0050HrmsSkillRateSettings { get; set; } = new List<T0050HrmsSkillRateSetting>();

    public virtual ICollection<T0052HrmsRecruitmentRequestApproval> T0052HrmsRecruitmentRequestApprovals { get; set; } = new List<T0052HrmsRecruitmentRequestApproval>();

    public virtual ICollection<T0052IncrementUtility> T0052IncrementUtilities { get; set; } = new List<T0052IncrementUtility>();

    public virtual ICollection<T0052ResumeFinalApproval> T0052ResumeFinalApprovals { get; set; } = new List<T0052ResumeFinalApproval>();

    public virtual ICollection<T0055SkillGeneralSetting> T0055SkillGeneralSettings { get; set; } = new List<T0055SkillGeneralSetting>();

    public virtual ICollection<T0060ResumeFinal> T0060ResumeFinals { get; set; } = new List<T0060ResumeFinal>();

    public virtual ICollection<T0080EmpMaster> T0080EmpMasters { get; set; } = new List<T0080EmpMaster>();

    public virtual ICollection<T0090AppMaster> T0090AppMasters { get; set; } = new List<T0090AppMaster>();
}
