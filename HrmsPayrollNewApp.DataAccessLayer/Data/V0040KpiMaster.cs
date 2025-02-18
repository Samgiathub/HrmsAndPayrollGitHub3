using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040KpiMaster
{
    public decimal KpiId { get; set; }

    public decimal CmpId { get; set; }

    public string? BranchId { get; set; }

    public string? BranchName { get; set; }

    public string? Kpi { get; set; }

    public decimal? Weightage { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal? CategoryId { get; set; }

    public string? CatName { get; set; }

    public string? DesignationId { get; set; }

    public string? DesigName { get; set; }

    public bool Active { get; set; }
}
