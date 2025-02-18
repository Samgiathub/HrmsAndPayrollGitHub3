using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090HrmsTraininigStatus
{
    public decimal TrainingAppId { get; set; }

    public decimal Expr1 { get; set; }

    public decimal TranAppDetailId { get; set; }

    public decimal LoginId { get; set; }

    public DateTime TrainingDate { get; set; }

    public string Place { get; set; } = null!;

    public string Faculty { get; set; } = null!;

    public string CompanyName { get; set; } = null!;

    public string? Description { get; set; }

    public decimal? TrainingCost { get; set; }

    public string AprStatus { get; set; } = null!;

    public DateTime? TrainingEndDate { get; set; }

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
}
