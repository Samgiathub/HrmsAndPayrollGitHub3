using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100TicketApproval
{
    public decimal TicketAprId { get; set; }

    public decimal? TicketAppId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? TicketTypeId { get; set; }

    public DateTime? TicketGenDate { get; set; }

    public DateTime? TicketAprDate { get; set; }

    public decimal? TicketDeptId { get; set; }

    public string? TicketPriority { get; set; }

    public string? TicketAprAttachment { get; set; }

    public string? TicketSolution { get; set; }

    public decimal? SEmpId { get; set; }

    public string? TicketStatus { get; set; }

    public DateTime? SysDatetime { get; set; }

    public decimal? UserId { get; set; }

    public string? TicketOnHoldReason { get; set; }

    public DateTime? TicketOnHoldDate { get; set; }

    public decimal? TicketOnHoldUser { get; set; }

    public decimal? FeedbackRating { get; set; }

    public DateTime? FeedbackDate { get; set; }

    public string? FeedbackSuggestion { get; set; }
}
