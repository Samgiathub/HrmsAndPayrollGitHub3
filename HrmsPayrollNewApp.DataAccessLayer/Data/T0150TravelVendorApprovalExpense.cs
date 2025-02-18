using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0150TravelVendorApprovalExpense
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal TravelAprovalId { get; set; }

    public decimal ProjectId { get; set; }

    public decimal VendorId { get; set; }

    public string? Description { get; set; }

    public decimal TravelSettlementId { get; set; }

    public decimal Quantity { get; set; }

    public decimal Rate { get; set; }

    public decimal TaxComponentId { get; set; }

    public decimal TaxPer { get; set; }

    public decimal TotalAmount { get; set; }

    public decimal TotalApprovedAmount { get; set; }

    public byte SelfPay { get; set; }

    public string? Remarks { get; set; }

    public decimal OrderTypeId { get; set; }

    public DateTime ModifyDate { get; set; }
}
