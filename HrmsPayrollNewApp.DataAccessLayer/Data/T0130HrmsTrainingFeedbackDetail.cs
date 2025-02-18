using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0130HrmsTrainingFeedbackDetail
{
    public decimal TrainingAprDetailId { get; set; }

    public decimal TrainingAprId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpSId { get; set; }

    public string? EmpFeedback { get; set; }

    public string? SuperiorFeedback { get; set; }

    public DateTime? EmpFeedbackDate { get; set; }

    public DateTime? SupFeedbackDate { get; set; }

    public decimal? EmpEvalRate { get; set; }

    public decimal? SupEvalRate { get; set; }

    public string IsAttend { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
