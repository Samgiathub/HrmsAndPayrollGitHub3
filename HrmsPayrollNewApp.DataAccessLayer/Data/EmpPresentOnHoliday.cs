using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class EmpPresentOnHoliday
{
    public decimal? RowId { get; set; }

    public decimal? EmpId { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal? PresOnHolDay { get; set; }
}
