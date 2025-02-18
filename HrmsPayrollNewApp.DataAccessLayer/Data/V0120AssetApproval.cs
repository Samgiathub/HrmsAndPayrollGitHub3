using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0120AssetApproval
{
    public string AssetName { get; set; } = null!;

    public string BrandName { get; set; } = null!;

    public string? WarrantyStarts { get; set; }

    public string? WarrantyEnds { get; set; }

    public string? PurchaseDate { get; set; }

    public string? Vendor { get; set; }

    public string TypeOfAsset { get; set; } = null!;

    public decimal? AssetApprovalId { get; set; }

    public string ModelName { get; set; } = null!;

    public string SerialNo { get; set; } = null!;

    public string AssetCode { get; set; } = null!;

    public decimal? CmpId { get; set; }

    public string? AssetStatus { get; set; }

    public string? ReturnDate { get; set; }

    public string? AllocationDate { get; set; }

    public decimal AssetId { get; set; }

    public string? ApprovalStatus { get; set; }
}
