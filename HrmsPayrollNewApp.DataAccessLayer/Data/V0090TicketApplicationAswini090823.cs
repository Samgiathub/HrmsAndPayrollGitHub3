using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090TicketApplicationAswini090823
{
    public decimal TicketAppId { get; set; }

    public string? TicketType { get; set; }

    public string? TicketDeptName { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public DateTime? TicketGenDate { get; set; }

    public string TicketStatus { get; set; } = null!;

    public string? TicketDescription { get; set; }

    public string? TicketPriority { get; set; }

    public decimal? TicketTypeId { get; set; }

    public decimal? TicketDeptId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? CmpId { get; set; }

    public string? TicketAttachment { get; set; }

    public byte IsEscalation { get; set; }

    public string? TicketPriorityId { get; set; }

    public string? OnHoldReason { get; set; }

    public string? TicketStatusFlag { get; set; }

    public decimal TicketAprId { get; set; }

    public string? TicketAprAttachment { get; set; }

    public byte IsCandidate { get; set; }

    public decimal? UserId { get; set; }

    public string? AppliedByName { get; set; }

    public decimal? AppliedById { get; set; }

    public string? AppliedByEmail { get; set; }

    public decimal EscalationHours { get; set; }

    public decimal? SendTo { get; set; }

    public string? SendToFullName { get; set; }
}
