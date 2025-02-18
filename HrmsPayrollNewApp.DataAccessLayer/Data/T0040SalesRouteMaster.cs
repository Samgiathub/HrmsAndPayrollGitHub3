using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040SalesRouteMaster
{
    public int RouteId { get; set; }

    public int CmpId { get; set; }

    public string? RouteName { get; set; }

    public string? RouteType { get; set; }

    public byte? IsActive { get; set; }

    public DateTime? InActiveDate { get; set; }

    public decimal? RouteNum { get; set; }

    public string? RouteDesc { get; set; }
}
