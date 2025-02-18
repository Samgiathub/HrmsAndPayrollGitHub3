using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040WarningMaster
{
    public decimal WarId { get; set; }

    public decimal CmpId { get; set; }

    public string? WarName { get; set; }

    public string? WarComments { get; set; }

    public decimal? DeductRate { get; set; }

    public string DeductType { get; set; } = null!;

    public decimal LevelId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0100WarningDetail> T0100WarningDetails { get; set; } = new List<T0100WarningDetail>();
}
