using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050HrmsAppraisalSetting
{
    public decimal ApprId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? GradeId { get; set; }

    public decimal? ActualCtc { get; set; }

    public decimal? Experience { get; set; }

    public decimal? MinAppraisal { get; set; }

    public decimal? MaxAppraisal { get; set; }

    public decimal? AppraisalDuration { get; set; }

    public DateTime? ForDate { get; set; }

    public virtual T0030BranchMaster? Branch { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0040DepartmentMaster? Dept { get; set; }

    public virtual T0040DesignationMaster? Desig { get; set; }

    public virtual T0040GradeMaster? Grade { get; set; }

    public virtual ICollection<T0055HrmsApprFeedbackQuestion> T0055HrmsApprFeedbackQuestions { get; set; } = new List<T0055HrmsApprFeedbackQuestion>();
}
