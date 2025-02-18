using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040TicketTypeMaster
{
    public decimal TicketTypeId { get; set; }

    public decimal? CmpId { get; set; }

    public string? TicketType { get; set; }

    public decimal? TicketDeptId { get; set; }

    public string? TicketDeptName { get; set; }

    public DateTime? SysDatetime { get; set; }

    public decimal? UserId { get; set; }
}
