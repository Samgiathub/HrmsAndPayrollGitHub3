using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0130HrmsTrainingFeedbackDetail
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

    public DateTime? TrainingDate { get; set; }

    public DateTime? TrainingEndDate { get; set; }

    public string? Place { get; set; }

    public string? Faculty { get; set; }

    public string? CompanyName { get; set; }

    public string? AprStatus { get; set; }

    public decimal? PostedEmpId { get; set; }

    public string? TrainingTitle { get; set; }

    public decimal? TrainingAppId { get; set; }
}
