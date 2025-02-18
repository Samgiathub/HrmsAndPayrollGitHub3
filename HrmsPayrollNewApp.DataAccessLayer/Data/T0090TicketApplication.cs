using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0090TicketApplication
{
    public decimal TicketAppId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? TicketTypeId { get; set; }

    public DateTime? TicketGenDate { get; set; }

    public decimal? TicketDeptId { get; set; }

    public string? TicketPriority { get; set; }

    public string? TicketAttachment { get; set; }

    public string? TicketDescription { get; set; }

    public string? TicketStatus { get; set; }

    public DateTime? SysDatetime { get; set; }

    public decimal? UserId { get; set; }

    public byte IsEscalation { get; set; }

    public byte? IsCandidate { get; set; }

    public decimal EscalationHours { get; set; }

    public decimal? SendTo { get; set; }
}
