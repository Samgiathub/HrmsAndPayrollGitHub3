using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class SalaryTempTable
{
    public int? SalTranId { get; set; }

    public int? EmpId { get; set; }

    public int? ItMAmount { get; set; }
}
