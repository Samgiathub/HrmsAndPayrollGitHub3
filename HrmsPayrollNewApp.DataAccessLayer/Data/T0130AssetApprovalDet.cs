using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0130AssetApprovalDet
{
    public decimal AssetApprDetId { get; set; }

    public decimal? AssetApprovalId { get; set; }

    public decimal CmpId { get; set; }

    public decimal AssetId { get; set; }

    public decimal BrandId { get; set; }

    public string? ModelName { get; set; }

    public string SerialNo { get; set; } = null!;

    public DateTime PurchaseDate { get; set; }

    public decimal LoginId { get; set; }

    public DateTime SystemDate { get; set; }

    public decimal? AssetMId { get; set; }

    public string? AssetCode { get; set; }

    public string? AssetStatus { get; set; }

    public DateTime? ReturnDate { get; set; }

    public decimal? ApplicationType { get; set; }

    public DateTime? AllocationDate { get; set; }

    public decimal? ReturnAssetApprovalId { get; set; }

    public string? ApprovalStatus { get; set; }

    public DateTime? InstallmentDate { get; set; }

    public decimal? InstallmentAmount { get; set; }

    public decimal? IssueAmount { get; set; }

    public decimal? SalTranId { get; set; }

    public string? DeductionType { get; set; }

    public decimal? TransferId { get; set; }

    public virtual T0120AssetApproval? AssetApproval { get; set; }

    public virtual T0040AssetDetail? AssetM { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
