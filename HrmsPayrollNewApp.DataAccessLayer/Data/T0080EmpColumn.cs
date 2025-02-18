using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0080EmpColumn
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal? Day { get; set; }

    public string? Comments { get; set; }

    public DateTime? Date { get; set; }

    public decimal? Rate { get; set; }
}
