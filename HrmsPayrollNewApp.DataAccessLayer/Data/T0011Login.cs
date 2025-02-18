using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0011Login
{
    public decimal LoginId { get; set; }

    public decimal CmpId { get; set; }

    public string LoginName { get; set; } = null!;

    public string LoginPassword { get; set; } = null!;

    public decimal? EmpId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? LoginRightsId { get; set; }

    public decimal? IsDefault { get; set; }

    public byte? IsHr { get; set; }

    public byte? IsAccou { get; set; }

    public string? EmailId { get; set; }

    public string? EmailIdAccou { get; set; }

    public byte IsActive { get; set; }

    public int EmpSearchType { get; set; }

    public string LoginAlias { get; set; } = null!;

    public DateTime? EffectiveDate { get; set; }

    public byte? TravelHelpDesk { get; set; }

    public string? BranchIdMulti { get; set; }

    public string? EmailIdHelpDesk { get; set; }

    public decimal IsIt { get; set; }

    public string? EmailIdIt { get; set; }

    public decimal? IsMedical { get; set; }

    public decimal? IsCanteen { get; set; }

    public string? EmailIdCanteen { get; set; }

    public virtual T0030BranchMaster? Branch { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0011LoginHistory> T0011LoginHistories { get; set; } = new List<T0011LoginHistory>();

    public virtual ICollection<T0015LoginBranchRight> T0015LoginBranchRights { get; set; } = new List<T0015LoginBranchRight>();

    public virtual ICollection<T0015LoginDetail> T0015LoginDetails { get; set; } = new List<T0015LoginDetail>();

    public virtual ICollection<T0015LoginFormRight> T0015LoginFormRights { get; set; } = new List<T0015LoginFormRight>();

    public virtual ICollection<T0015LoginRight> T0015LoginRights { get; set; } = new List<T0015LoginRight>();

    public virtual ICollection<T0040FormMaster> T0040FormMasters { get; set; } = new List<T0040FormMaster>();

    public virtual ICollection<T0040HrmsGeneralSetting> T0040HrmsGeneralSettings { get; set; } = new List<T0040HrmsGeneralSetting>();

    public virtual ICollection<T0040HrmsGoalMaster> T0040HrmsGoalMasters { get; set; } = new List<T0040HrmsGoalMaster>();

    public virtual ICollection<T0040ProjectStatus> T0040ProjectStatuses { get; set; } = new List<T0040ProjectStatus>();

    public virtual ICollection<T0040TaskMaster> T0040TaskMasters { get; set; } = new List<T0040TaskMaster>();

    public virtual ICollection<T0040TaxLimit> T0040TaxLimits { get; set; } = new List<T0040TaxLimit>();

    public virtual ICollection<T0040TsProjectMaster> T0040TsProjectMasters { get; set; } = new List<T0040TsProjectMaster>();

    public virtual ICollection<T0040WeekoffMaster> T0040WeekoffMasters { get; set; } = new List<T0040WeekoffMaster>();

    public virtual ICollection<T0050HrmsRecruitmentRequest> T0050HrmsRecruitmentRequests { get; set; } = new List<T0050HrmsRecruitmentRequest>();

    public virtual ICollection<T0050TaskDetail> T0050TaskDetails { get; set; } = new List<T0050TaskDetail>();

    public virtual ICollection<T0052HrmsPostedRecruitment> T0052HrmsPostedRecruitments { get; set; } = new List<T0052HrmsPostedRecruitment>();

    public virtual ICollection<T0055HrmsApprFeedbackQuestion> T0055HrmsApprFeedbackQuestions { get; set; } = new List<T0055HrmsApprFeedbackQuestion>();

    public virtual ICollection<T0060HrmsInterviewFeedbackDetail> T0060HrmsInterviewFeedbackDetails { get; set; } = new List<T0060HrmsInterviewFeedbackDetail>();

    public virtual ICollection<T0060ResumeFinal> T0060ResumeFinals { get; set; } = new List<T0060ResumeFinal>();

    public virtual ICollection<T0070ItMaster> T0070ItMasters { get; set; } = new List<T0070ItMaster>();

    public virtual ICollection<T0080EmpMaster> T0080EmpMasters { get; set; } = new List<T0080EmpMaster>();

    public virtual ICollection<T0090CommonRequestDetail> T0090CommonRequestDetails { get; set; } = new List<T0090CommonRequestDetail>();
}
