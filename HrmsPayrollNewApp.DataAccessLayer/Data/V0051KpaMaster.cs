using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0051KpaMaster
{
    public decimal KpaId { get; set; }

    public decimal CmpId { get; set; }

    public string? KpaContent { get; set; }

    public string? KpaTarget { get; set; }

    public decimal? KpaWeightage { get; set; }

    public string? DesigId { get; set; }

    public string? DesigName { get; set; }

    public string? DeptId { get; set; }

    public string? DeptName { get; set; }

    public DateTime? EffectiveDate { get; set; }
}
