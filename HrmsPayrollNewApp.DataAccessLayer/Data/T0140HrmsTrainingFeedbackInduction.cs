using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0140HrmsTrainingFeedbackInduction
{
    public decimal TranFeedbackId { get; set; }

    public decimal TranEmpDetailId { get; set; }

    public decimal? CmpId { get; set; }

    public int? IsAttend { get; set; }

    public string? Reason { get; set; }

    public decimal? EmpScore { get; set; }

    public decimal? SupScore { get; set; }

    public string? SupComments { get; set; }

    public string? SupSuggestion { get; set; }

    public decimal? EmpSId { get; set; }

    public int? Status { get; set; }

    public int? TrainingId { get; set; }

    public int? InductionTrainingType { get; set; }

    public byte? TrainingAttemptCount { get; set; }

    public decimal? LastAttemptScore { get; set; }
}
