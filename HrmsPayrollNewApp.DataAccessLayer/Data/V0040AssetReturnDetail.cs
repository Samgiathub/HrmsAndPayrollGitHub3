using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040AssetReturnDetail
{
    public string BrandName { get; set; } = null!;

    public string AssetName { get; set; } = null!;

    public decimal AssetId { get; set; }

    public DateTime? ApplicationDate { get; set; }

    public string? ApplicationStatus { get; set; }

    public string? ModelName { get; set; }

    public string SerialNo { get; set; } = null!;

    public DateTime? AllocationDate { get; set; }

    public string? AssetCode { get; set; }

    public decimal? EmpId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? AssetMId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal BrandId { get; set; }

    public DateTime PurchaseDate { get; set; }

    public DateTime? ReturnDate { get; set; }

    public decimal? AssetApprovalId { get; set; }
}
