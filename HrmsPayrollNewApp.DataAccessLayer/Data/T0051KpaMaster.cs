using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0051KpaMaster
{
    public decimal KpaId { get; set; }

    public decimal CmpId { get; set; }

    public string? DesigId { get; set; }

    public string? KpaContent { get; set; }

    public string? KpaTarget { get; set; }

    public decimal? KpaWeightage { get; set; }

    public string? DeptId { get; set; }

    public DateTime? EffectiveDate { get; set; }

    public decimal? KpaTypeId { get; set; }

    public string? KpaPerformaceMeasure { get; set; }

    public DateTime? CompletionDate { get; set; }

    public string? AttachDocs { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0040HrmsKpatypeMaster? KpaType { get; set; }
}
