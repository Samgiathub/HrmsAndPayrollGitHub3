using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0140HrmsTrainingFeedback
{
    public decimal? TrainingAppId { get; set; }

    public decimal? TrainingAprId { get; set; }

    public int? EmpTranStatus { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? TrainingId { get; set; }

    public DateTime? TrainingDate { get; set; }

    public string? TrainingName { get; set; }

    public string? Description { get; set; }

    public string? Faculty { get; set; }

    public string? Place { get; set; }

    public DateTime? TrainingEndDate { get; set; }

    public string? Type { get; set; }

    public int? EmpFeedback { get; set; }

    public int? SupFeedback { get; set; }

    public string? ProviderName { get; set; }

    public decimal? TrainingCost { get; set; }

    public decimal? TrainingProId { get; set; }

    public string? GrdId { get; set; }

    public int? AprStatus { get; set; }

    public string? EmpFirstName { get; set; }

    public string? EmpFullName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public string? DeptName { get; set; }

    public string? BranchName { get; set; }

    public string? DesigName { get; set; }

    public string IsAttendName { get; set; } = null!;

    public string? EmpFullNameNew { get; set; }

    public decimal TranFeedbackId { get; set; }

    public decimal TranEmpDetailId { get; set; }

    public decimal? CmpId { get; set; }

    public int? IsAttend { get; set; }

    public string? Reason { get; set; }

    public decimal? EmpScore { get; set; }

    public decimal? SupScore { get; set; }

    public string? SupSuggestion { get; set; }

    public string? SupComments { get; set; }

    public decimal? EmpSId { get; set; }

    public string? TrainingCode { get; set; }

    public decimal? AppcmpId { get; set; }
}
