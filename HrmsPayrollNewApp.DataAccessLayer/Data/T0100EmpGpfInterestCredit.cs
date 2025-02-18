using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100EmpGpfInterestCredit
{
    public decimal CmpId { get; set; }

    public decimal TranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal AdId { get; set; }

    public DateTime FromDate { get; set; }

    public DateTime ToDate { get; set; }

    public DateTime YearStDate { get; set; }

    public DateTime YearEndDate { get; set; }

    public decimal Amount { get; set; }

    public DateTime? SystemDate { get; set; }
}
