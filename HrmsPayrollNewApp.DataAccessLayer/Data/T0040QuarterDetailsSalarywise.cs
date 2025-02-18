using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040QuarterDetailsSalarywise
{
    public int CmpId { get; set; }

    public DateTime MonthStDate { get; set; }

    public DateTime MonthEndDate { get; set; }

    public int Qtr { get; set; }
}
