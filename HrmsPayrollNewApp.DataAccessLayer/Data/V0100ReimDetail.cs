using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100ReimDetail
{
    public string RimbName { get; set; } = null!;

    public decimal RimbId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal RimbAmount { get; set; }

    public decimal RimbTranId { get; set; }
}
