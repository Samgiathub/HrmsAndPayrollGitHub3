using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040AssetDetails1
{
    public string AssetName { get; set; } = null!;

    public string BrandName { get; set; } = null!;

    public DateTime WarrantyStarts { get; set; }

    public DateTime WarrantyEnds { get; set; }

    public string Vendor { get; set; } = null!;

    public string TypeOfAsset { get; set; } = null!;

    public decimal? AssetApprovalId { get; set; }

    public string ModelName { get; set; } = null!;

    public string SerialNo { get; set; } = null!;

    public string AssetCode { get; set; } = null!;

    public decimal CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public string? PurchaseDate { get; set; }

    public string? ReturnDate { get; set; }

    public string Type { get; set; } = null!;
}
