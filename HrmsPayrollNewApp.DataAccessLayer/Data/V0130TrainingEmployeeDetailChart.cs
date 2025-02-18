using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0130TrainingEmployeeDetailChart
{
    public decimal TranEmpDetailId { get; set; }

    public decimal? TrainingAppId { get; set; }

    public decimal? TrainingAprId { get; set; }

    public int? EmpTranStatus { get; set; }

    public decimal CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? TrainingId { get; set; }

    public DateTime? TrainingDate { get; set; }

    public string? TrainingName { get; set; }

    public string Type { get; set; } = null!;

    public string? ProviderName { get; set; }

    public string? GrdId { get; set; }

    public string? EmpFirstName { get; set; }

    public string? EmpFullName { get; set; }

    public decimal? EmpCode { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public string? DeptName { get; set; }

    public string? BranchName { get; set; }

    public string? DesigName { get; set; }

    public string? EmpFullNameNew { get; set; }

    public decimal? TrainingProId { get; set; }

    public DateTime? TrainingEndDate { get; set; }

    public string IsAttendName { get; set; } = null!;

    public decimal TranFeedbackId { get; set; }

    public string? Reason { get; set; }

    public decimal? EmpScore { get; set; }

    public decimal? SupScore { get; set; }

    public string? SupComments { get; set; }

    public string? SupSuggestion { get; set; }

    public int? Status { get; set; }

    public int? IsAttend { get; set; }
}
