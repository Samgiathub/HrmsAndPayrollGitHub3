using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0140BondTransaction
{
    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public decimal BondTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal BondId { get; set; }

    public string BondName { get; set; } = null!;

    public decimal EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal BondOpening { get; set; }

    public decimal BondIssue { get; set; }

    public decimal BondReturn { get; set; }

    public decimal BondClosing { get; set; }
}
