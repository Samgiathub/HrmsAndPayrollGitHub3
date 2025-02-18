using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0200SalaryBudget
{
    public decimal SalBudgetId { get; set; }

    public string? SalBudgetType { get; set; }

    public DateTime? SalBudgetDate { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? CreatedBy { get; set; }

    public DateTime? CreatedDate { get; set; }

    public decimal? ModifiedBy { get; set; }

    public DateTime? ModifiedDate { get; set; }

    public string? BranchIds { get; set; }

    public string? SubBranchIds { get; set; }

    public string? GradeIds { get; set; }

    public string? TypeIds { get; set; }

    public string? DeptIds { get; set; }

    public string? DesigIds { get; set; }

    public string? CatIds { get; set; }

    public string? BusSegmentIds { get; set; }

    public string? VerticalIds { get; set; }

    public string? SubVerticalIds { get; set; }

    public DateTime? AppraisalDateFrom { get; set; }

    public DateTime? AppraisalDateTo { get; set; }
}
