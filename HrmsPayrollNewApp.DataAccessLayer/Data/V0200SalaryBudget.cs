using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0200SalaryBudget
{
    public decimal SalBudgetId { get; set; }

    public string? SalBudgetType { get; set; }

    public DateTime? SalBudgetDate { get; set; }

    public decimal? CmpId { get; set; }

    public string? DeptIds { get; set; }

    public string? BranchIds { get; set; }

    public string? SubbranchIds { get; set; }

    public string? SubverticalIds { get; set; }

    public string? VerticalIds { get; set; }

    public string? TypeIds { get; set; }

    public string? CatIds { get; set; }

    public string? DesigIds { get; set; }

    public string? GradeIds { get; set; }

    public string? BusSegmentIds { get; set; }

    public string? DeptName { get; set; }

    public string? BranchName { get; set; }

    public string? SubBranchName { get; set; }

    public string? DesigName { get; set; }

    public string? GradeName { get; set; }

    public string? CatName { get; set; }

    public string? TypeName { get; set; }

    public string? SegmentName { get; set; }

    public string? VerticalName { get; set; }

    public string? SubVerticalName { get; set; }
}
