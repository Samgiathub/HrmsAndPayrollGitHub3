using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040TicketPriority
{
    public decimal TranId { get; set; }

    public decimal? CmpId { get; set; }

    public string? PriorityName { get; set; }

    public string? HoursLimit { get; set; }

    public decimal? UserId { get; set; }

    public DateTime? ModifyDate { get; set; }
}
