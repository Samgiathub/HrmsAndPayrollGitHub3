using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0080EmpPresentDay
{
    public int Id { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? Present { get; set; }

    public decimal? Wo { get; set; }

    public decimal? Ho { get; set; }

    public decimal? Od { get; set; }

    public decimal? Absent { get; set; }

    public decimal? Leave { get; set; }

    public decimal? Total { get; set; }

    public decimal? DPresent { get; set; }

    public DateTime? ForDate { get; set; }
}
