using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040AssetAllocation
{
    public string AssetName { get; set; } = null!;

    public string BrandName { get; set; } = null!;

    public string AssetCode { get; set; } = null!;

    public string SerialNo { get; set; } = null!;

    public DateTime? AllocationDate { get; set; }

    public string Vendor { get; set; } = null!;

    public string TypeOfAsset { get; set; } = null!;

    public decimal? AssetApprovalId { get; set; }

    public string ModelName { get; set; } = null!;

    public string SerialNo1 { get; set; } = null!;

    public string Expr1 { get; set; } = null!;

    public decimal CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public string? ReturnDate { get; set; }

    public string Type { get; set; } = null!;

    public string? EmpFullName { get; set; }

    public string? BranchName { get; set; }

    public decimal AssetMId { get; set; }

    public decimal AssetId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string AssetStatus { get; set; } = null!;

    public decimal BrandId { get; set; }

    public double? InvoiceAmount { get; set; }

    public decimal? IssueAmount { get; set; }
}
