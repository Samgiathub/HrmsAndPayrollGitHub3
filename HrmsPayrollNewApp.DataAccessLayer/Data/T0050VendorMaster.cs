using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050VendorMaster
{
    public decimal VendorId { get; set; }

    public decimal CmpId { get; set; }

    public string VendorName { get; set; } = null!;

    public string? VendorAddress { get; set; }

    public string? VendorContactNo { get; set; }

    public string? VendorCompanyWebsite { get; set; }

    public string? AccountHolderName { get; set; }

    public string? BankName { get; set; }

    public string? BranchName { get; set; }

    public string? AccountNo { get; set; }

    public string? IifcCode { get; set; }

    public string? Remarks { get; set; }

    public DateTime? ModifyDate { get; set; }

    public string? VendorCode { get; set; }
}
