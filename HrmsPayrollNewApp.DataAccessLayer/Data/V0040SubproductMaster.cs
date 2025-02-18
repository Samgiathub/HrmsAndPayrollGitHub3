using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040SubproductMaster
{
    public decimal SubProductId { get; set; }

    public decimal ProductId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LoginId { get; set; }

    public string SubProductName { get; set; } = null!;

    public string? UnitName { get; set; }

    public DateTime? SystemDate { get; set; }

    public string? ProductName { get; set; }

    public string Unit { get; set; } = null!;
}
