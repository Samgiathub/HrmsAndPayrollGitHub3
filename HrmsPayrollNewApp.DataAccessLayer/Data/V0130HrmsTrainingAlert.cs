using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0130HrmsTrainingAlert
{
    public decimal? EmpId { get; set; }

    public decimal TrainingAprId { get; set; }

    public decimal TranAlertId { get; set; }

    public string? Comments { get; set; }

    public decimal? AlertsDays { get; set; }

    public DateTime? TrainingDate { get; set; }

    public string? Description { get; set; }

    public string? TrainingName { get; set; }

    public decimal? AlertsStartDays { get; set; }

    public decimal CmpId { get; set; }

    public decimal? DeptId { get; set; }

    public string? GrdId { get; set; }

    public int? AprStatus { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? Expr1 { get; set; }

    public decimal? Expr2 { get; set; }

    public decimal? DesigId { get; set; }

    public string? DesigName { get; set; }

    public string? BranchName { get; set; }

    public string? GrdName { get; set; }

    public string? DeptName { get; set; }

    public DateTime? TrainingEndDate { get; set; }
}
