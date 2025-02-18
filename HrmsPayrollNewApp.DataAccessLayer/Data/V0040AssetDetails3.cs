using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040AssetDetails3
{
    public string AssetName { get; set; } = null!;

    public string SerialNo { get; set; } = null!;

    public string Model { get; set; } = null!;

    public string? PurchaseDate { get; set; }

    public string AssetCode { get; set; } = null!;

    public decimal AssetId { get; set; }

    public decimal CmpId { get; set; }

    public string BrandName { get; set; } = null!;

    public decimal BrandId { get; set; }

    public bool? Allocation { get; set; }

    public string? AssetStatus { get; set; }

    public decimal AssetMId { get; set; }

    public DateTime? AllocationDate { get; set; }

    public string TypeOfAsset { get; set; } = null!;
}
