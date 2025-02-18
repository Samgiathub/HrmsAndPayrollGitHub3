using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040AssetDetail
{
    public decimal AssetMId { get; set; }

    public decimal CmpId { get; set; }

    public decimal AssetId { get; set; }

    public string Description { get; set; } = null!;

    public string TypeOfAsset { get; set; } = null!;

    public string SerialNo { get; set; } = null!;

    public decimal BrandId { get; set; }

    public string Model { get; set; } = null!;

    public string Vendor { get; set; } = null!;

    public string? Status { get; set; }

    public DateTime PurchaseDate { get; set; }

    public DateTime WarrantyStarts { get; set; }

    public DateTime WarrantyEnds { get; set; }

    public string Image { get; set; } = null!;

    public string AssetCode { get; set; } = null!;

    public bool? Allocation { get; set; }

    public string? AssetStatus { get; set; }

    public string? InvoiceNo { get; set; }

    public double? InvoiceAmount { get; set; }

    public string? AttachDoc { get; set; }

    public string? PartNo { get; set; }

    public string? ImeiNo { get; set; }

    public string? MacAddress { get; set; }

    public string? VendorAddress { get; set; }

    public DateTime? InvoiceDate { get; set; }

    public string? Pono { get; set; }

    public DateTime? PonoDate { get; set; }

    public string? City { get; set; }

    public string? ContactPerson { get; set; }

    public string? ContactNo { get; set; }

    public DateTime? DisposeDate { get; set; }

    public decimal? VendorId { get; set; }

    public int? BranchId { get; set; }

    public virtual T0040AssetMaster Asset { get; set; } = null!;

    public virtual T0040BrandMaster Brand { get; set; } = null!;

    public virtual ICollection<T0090HrmsAssetAllocation> T0090HrmsAssetAllocations { get; set; } = new List<T0090HrmsAssetAllocation>();

    public virtual ICollection<T0090HrmsAssetInstallationDetail> T0090HrmsAssetInstallationDetails { get; set; } = new List<T0090HrmsAssetInstallationDetail>();

    public virtual ICollection<T0110AssetApplicationDetail> T0110AssetApplicationDetails { get; set; } = new List<T0110AssetApplicationDetail>();

    public virtual ICollection<T0110AssetInstallationDetail> T0110AssetInstallationDetails { get; set; } = new List<T0110AssetInstallationDetail>();

    public virtual ICollection<T0110AssetTitleDetail> T0110AssetTitleDetails { get; set; } = new List<T0110AssetTitleDetail>();

    public virtual ICollection<T0130AssetApprovalDet> T0130AssetApprovalDets { get; set; } = new List<T0130AssetApprovalDet>();

    public virtual ICollection<T0140AssetTransaction> T0140AssetTransactions { get; set; } = new List<T0140AssetTransaction>();

    public virtual T0040VendorMaster? VendorNavigation { get; set; }
}
