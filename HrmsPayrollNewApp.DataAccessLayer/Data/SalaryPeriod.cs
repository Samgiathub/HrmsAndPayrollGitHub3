using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class SalaryPeriod
{
    public decimal SalaryPeriodId { get; set; }

    public decimal Month { get; set; }

    public decimal Year { get; set; }

    public DateTime FromDate { get; set; }

    public DateTime EndDate { get; set; }
}
