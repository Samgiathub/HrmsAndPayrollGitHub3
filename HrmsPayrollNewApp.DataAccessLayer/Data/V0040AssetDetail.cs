using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040AssetDetail
{
    public string AssetName { get; set; } = null!;

    public string TypeOfAsset { get; set; } = null!;

    public string SerialNo { get; set; } = null!;

    public string? BrandName { get; set; }

    public decimal CmpId { get; set; }

    public string AssetCode { get; set; } = null!;

    public decimal AssetMId { get; set; }

    public string Allocation { get; set; } = null!;

    public string? PurchaseDate { get; set; }

    public string? AssetStatus { get; set; }

    public decimal AssetId { get; set; }

    public string Description { get; set; } = null!;

    public string? Pono { get; set; }

    public DateTime? PonoDate { get; set; }

    public string? InvoiceNo { get; set; }

    public double? InvoiceAmount { get; set; }

    public DateTime? InvoiceDate { get; set; }

    public string Model { get; set; } = null!;

    public decimal? VendorId { get; set; }

    public int? BranchId { get; set; }
}
