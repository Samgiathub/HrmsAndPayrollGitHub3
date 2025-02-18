using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T9999BankTransferExport
{
    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public string EmpFullName { get; set; } = null!;

    public string Month { get; set; } = null!;

    public decimal Year { get; set; }

    public DateTime GenerateDate { get; set; }

    public string FileName { get; set; } = null!;

    public string? RegerateFlag { get; set; }

    public string? Reason { get; set; }

    public decimal? ModifiedBy { get; set; }

    public DateTime? ModifiedDate { get; set; }

    public string? Flag { get; set; }
}
