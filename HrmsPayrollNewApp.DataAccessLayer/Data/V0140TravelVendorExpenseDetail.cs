using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0140TravelVendorExpenseDetail
{
    public decimal TranId { get; set; }

    public decimal TravelApprovalId { get; set; }

    public decimal ProjectId { get; set; }

    public string ProjectName { get; set; } = null!;

    public decimal VendorId { get; set; }

    public string VendorName { get; set; } = null!;

    public string? Description { get; set; }

    public decimal Quantity { get; set; }

    public decimal Rate { get; set; }

    public decimal? TaxComponents { get; set; }

    public decimal TaxPer { get; set; }

    public decimal TotalAmount { get; set; }

    public string? Remarks { get; set; }

    public decimal? TravelSettlementId { get; set; }

    public string TaxCmpntName { get; set; } = null!;

    public string SelfPay { get; set; } = null!;

    public decimal OrderTypeId { get; set; }

    public string OrderTypeName { get; set; } = null!;

    public string SiteId { get; set; } = null!;

    public decimal CmpId { get; set; }
}
