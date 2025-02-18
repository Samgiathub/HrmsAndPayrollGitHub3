using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0140TravelVendorExpenseRequest
{
    public decimal TranId { get; set; }

    public decimal TravelApprovalId { get; set; }

    public decimal ProjectId { get; set; }

    public decimal VendorId { get; set; }

    public string? Description { get; set; }

    public decimal Quantity { get; set; }

    public decimal Rate { get; set; }

    public decimal? TaxComponents { get; set; }

    public decimal? TaxPercentage { get; set; }

    public decimal TotalAmount { get; set; }

    public string? Remarks { get; set; }

    public decimal EmpId { get; set; }

    public byte? SelfPay { get; set; }

    public decimal CmpId { get; set; }

    public decimal OrderTypeId { get; set; }

    public DateTime ModifyDate { get; set; }
}
