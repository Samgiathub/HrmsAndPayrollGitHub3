using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0095TicketEscalation
{
    public decimal TranId { get; set; }

    public decimal? TicketAppId { get; set; }

    public decimal? EmpId { get; set; }

    public DateTime? GenDate { get; set; }

    public string? EmailId { get; set; }

    public decimal? TicketLevel { get; set; }
}
