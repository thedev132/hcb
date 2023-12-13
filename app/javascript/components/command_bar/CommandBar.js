/* eslint react/prop-types:0 */

import React, { useState, useEffect } from "react";
import {
	KBarProvider,
	KBarPortal,
	KBarPositioner,
	KBarAnimator,
	KBarSearch,
	useRegisterActions,
	KBarResults,
	useMatches,
	Priority,
} from "kbar";
import Icon from "@hackclub/icons";

const searchStyle = {
	padding: "12px 16px",
	fontSize: "16px",
	width: "100%",
	boxSizing: "border-box",
	outline: "none",
	border: "none",
	background: "var(--kbar-background)",
	color: "var(--kbar-foreground)",
};

const animatorStyle = {
	maxWidth: "600px",
	width: "100%",
	background: "var(--kbar-background)",
	color: "var(--kbar-foreground)",
	borderRadius: "8px",
	overflow: "hidden",
	boxShadow: "0px 6px 20px rgb(0 0 0 / 20%)",
};

const groupNameStyle = {
	padding: "8px 16px",
	fontSize: "10px",
	textTransform: "uppercase",
	opacity: 0.5,
};

function ActionRegister() {
	const [actions, setActions] = useState([]);

	useRegisterActions(actions, [actions]);

	useEffect(() => {
		async function fetchOrganizations() {
			try {
				const response = await fetch("/events.json");
				if (response.ok) {
					const data = await response.json();
					setActions([
						...actions,
						...data.map((event) => ({
							id: event.slug,
							name: event.name,
							icon: event.logo && event.logo != "none"  ? (
								<img
									src={event.logo}
									height="16px"
									width="16px"
									style={{ borderRadius: "4px" }}
								/>
							) : (
								<Icon glyph="bank-account" size={16} />
							),
							priority: !event.member ? Priority.LOW : Priority.HIGH,
							section: "Organizations",
						})),
						...data.map((event) => ({
							id: `${event.slug}-home`,
							name: "Home",
							perform: () => (window.location.pathname = `/${event.slug}`),
							icon: <Icon glyph="home" size={16} />,
							parent: event.slug,
						})),
						...data.map((event) => ({
							id: `${event.slug}-donations`,
							name: "Donations",
							perform: () =>
								(window.location.pathname = `/${event.slug}/donations`),
							icon: <Icon glyph="support" size={16} />,
							parent: event.slug,
						})),
						...data.map((event) => ({
							id: `${event.slug}-invoices`,
							name: "Invoices",
							perform: () =>
								(window.location.pathname = `/${event.slug}/invoices`),
							icon: <Icon glyph="briefcase" size={16} />,
							parent: event.slug,
						})),
						...data.map((event) => ({
							id: `${event.slug}-account-number`,
							name: "Account & routing number",
							perform: () =>
								(window.location.pathname = `/${event.slug}/account-number`),
							icon: <Icon glyph="bank-account" size={16} />,
							parent: event.slug,
						})),
						...data.map((event) => ({
							id: `${event.slug}-check-deposit`,
							name: "Check deposit",
							perform: () =>
								(window.location.pathname = `/${event.slug}/check-deposits`),
							icon: <Icon glyph="attachment" size={16} />,
							parent: event.slug,
						})),
						...data.map((event) => ({
							id: `${event.slug}-cards`,
							name: "Cards",
							perform: () =>
								(window.location.pathname = `/${event.slug}/cards`),
							icon: <Icon glyph="card" size={16} />,
							parent: event.slug,
						})),
						...data.map((event) => ({
							id: `${event.slug}-transfers`,
							name: "Transfers",
							perform: () =>
								(window.location.pathname = `/${event.slug}/transfers`),
							icon: <Icon glyph="payment-transfer" size={16} />,
							parent: event.slug,
						})),
						...data.map((event) => ({
							id: `${event.slug}-team`,
							name: "Team",
							perform: () => (window.location.pathname = `/${event.slug}/team`),
							icon: <Icon glyph="leader" size={16} />,
							parent: event.slug,
						})),
						...data.map((event) => ({
							id: `${event.slug}-perks`,
							name: "Perks",
							perform: () =>
								(window.location.pathname = `/${event.slug}/promotions`),
							icon: <Icon glyph="shirt" size={16} />,
							parent: event.slug,
						})),
						...data.map((event) => ({
							id: `${event.slug}-documentation`,
							name: "Documentation",
							perform: () =>
								(window.location.pathname = `/${event.slug}/documentation`),
							icon: <Icon glyph="info" size={16} />,
							parent: event.slug,
						})),
						...data.map((event) => ({
							id: `${event.slug}-settings`,
							name: "Settings",
							perform: () =>
								(window.location.pathname = `/${event.slug}/settings`),
							icon: <Icon glyph="settings" size={16} />,
							parent: event.slug,
						})),
					]);
				}
			} catch (error) {
				console.error("Error:", error);
			}
		}
		fetchOrganizations();
	}, []);
	return <></>;
}

export default function CommandBar({admin = false, adminUrls = {}}) {
	const initalActions = [
		{
			id: "home",
			name: "Home",
			keywords: "index",
			perform: () => (window.location.pathname = "/"),
			icon: <Icon glyph="home" size={16} />,
			priority: Priority.HIGH,
		},
		{
			id: "cards",
			name: "Cards",
			keywords: "cards",
			perform: () => (window.location.pathname = "/my/cards"),
			icon: <Icon glyph="card" size={16} />,
			priority: Priority.HIGH,
		},
		{
			id: "receipts",
			name: "Receipts",
			keywords: "receipts inbox",
			perform: () => (window.location.pathname = "/my/inbox"),
			icon: <Icon glyph="payment-docs" size={16} />,
			priority: Priority.HIGH,
		},
		{
			id: "settings",
			name: "Settings",
			keywords: "settings",
			perform: () => (window.location.pathname = "/my/settings"),
			icon: <Icon glyph="settings" size={16} />,
			priority: Priority.HIGH,
		},
		{
			id: "change_theme",
			name: "Change Theme",
			keywords: "dark light", // eslint-disable-next-line no-undef
			perform: () => BK.toggleDark(),
			section: 'Actions',
			icon: <Icon glyph="idea" size={16} />,
			priority: Priority.HIGH,
		},
		{
			id: "logout",
			name: "Logout",
			keywords: "sign out logout log out",
			perform: () => (window.location.pathname = "/users/logout"),
			section: 'Actions',
			icon: <Icon glyph="door-leave" size={16} />,
			priority: Priority.HIGH,
		},
	];

	const adminToolsCards = [
		{
			id: "admin_tool_1",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "Applications",
			icon: <Icon glyph="align-left" size={16} />,
			perform: () =>
				(window.location.href = adminUrls["Applications"]),
		},
		{
			id: "admin_tool_2",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "OnBoard ID",
			icon: <Icon glyph="emoji" size={16} />,
			perform: () =>
				(window.location.href = adminUrls["OnBoard ID"]),
		},
		{
			id: "admin_tool_3",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "Ledger",
			icon: <Icon glyph="list" size={16} />,
			perform: () => (window.location.href = "/admin/ledger"),
		},
		{
			id: "admin_tool_4",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "ACH",
			icon: <Icon glyph="payment-transfer" size={16} />,
			perform: () => (window.location.href = "/admin/ach"),
		},
		{
			id: "admin_tool_5",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "Check",
			icon: <Icon glyph="payment-docs" size={16} />,
			perform: () => (window.location.href = "/admin/increase_checks"),
		},
		{
			id: "admin_tool_6",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "Grants",
			icon: <Icon glyph="support" size={16} />,
			perform: () => (window.location.href = "/admin/grants"),
		},
		{
			id: "admin_tool_7",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "Wires",
			icon: <Icon glyph="bolt" size={16} />,
			perform: () =>
				(window.location.href = adminUrls["Wires"]),
		},
		{
			id: "admin_tool_8",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "PayPal",
			icon: <Icon glyph="grid" size={16} />,
			perform: () =>
				(window.location.href = adminUrls["PayPal"]),
		},
		{
			id: "admin_tool_9",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "Disbursements",
			icon: <Icon glyph="payment-transfer" size={16} />,
			perform: () => (window.location.href = "/admin/disbursements"),
		},
		{
			id: "admin_tool_10",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "Deletion Requests",
			icon: <Icon glyph="member-remove" size={16} />,
			perform: () =>
				(window.location.href = "/organizer_position_deletion_requests"),
		},
		{
			id: "admin_tool_11",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "Disputes",
			icon: <Icon glyph="important" size={16} />,
			perform: () =>
				(window.location.href = adminUrls["Disputes"]),
		},
		{
			id: "admin_tool_12",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "Feedback",
			icon: <Icon glyph="message-new" size={16} />,
			perform: () =>
				(window.location.href = adminUrls["Feedback"]),
		},
		{
			id: "admin_tool_13",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "FIRST Grants",
			icon: <Icon glyph="sam" size={16} />,
			perform: () =>
				(window.location.href = adminUrls["FIRST Grants"]),
		},
		{
			id: "admin_tool_14",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "Organizations",
			icon: <Icon glyph="explore" size={16} />,
			perform: () => (window.location.href = "/admin/events"),
		},
		{
			id: "admin_tool_15",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "Users",
			icon: <Icon glyph="leaders" size={16} />,
			perform: () => (window.location.href = "/admin/users"),
		},
		{
			id: "admin_tool_16",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "Donations",
			icon: <Icon glyph="support" size={16} />,
			perform: () => (window.location.href = "/admin/donations"),
		},
		{
			id: "admin_tool_17",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "Invoices",
			icon: <Icon glyph="docs-fill" size={16} />,
			perform: () => (window.location.href = "/admin/invoices"),
		},
		{
			id: "admin_tool_18",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "Sponsors",
			icon: <Icon glyph="purse" size={16} />,
			perform: () => (window.location.href = "/admin/sponsors"),
		},
		{
			id: "admin_tool_19",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "Cards",
			icon: <Icon glyph="card" size={16} />,
			perform: () => (window.location.href = "/admin/stripe_cards"),
		},
		{
			id: "admin_tool_20",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "Google Workspaces",
			icon: <Icon glyph="google" size={16} />,
			perform: () => (window.location.href = "/admin/google_workspaces"),
		},
		{
			id: "admin_tool_21",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "Stickers",
			icon: <Icon glyph="sticker" size={16} />,
			perform: () =>
				(window.location.href = adminUrls["Stickers"]),
		},
		{
			id: "admin_tool_22",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "Wallets",
			icon: <Icon glyph="send" size={16} />,
			perform: () =>
				(window.location.href = adminUrls["Wallets"]),
		},
		{
			id: "admin_tool_23",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "Hackathons",
			icon: <Icon glyph="event-code" size={16} />,
			perform: () =>
				(window.location.href = adminUrls["Hackathons"]),
		},
		{
			id: "admin_tool_24",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "Sendy",
			icon: <Icon glyph="email-fill" size={16} />,
			perform: () =>
				(window.location.href = adminUrls["Sendy"]),
		},
		{
			id: "admin_tool_25",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "1Password",
			icon: <Icon glyph="private" size={16} />,
			perform: () =>
				(window.location.href = adminUrls["1Password"]),
		},
		{
			id: "admin_tool_26",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "Domains",
			icon: <Icon glyph="web" size={16} />,
			perform: () =>
				(window.location.href = adminUrls["Domains"]),
		},
		{
			id: "admin_tool_27",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "PVSA",
			icon: <Icon glyph="thumbsup" size={16} />,
			perform: () =>
				(window.location.href = adminUrls["PVSA"]),
		},
		{
			id: "admin_tool_28",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "The Event Helper",
			icon: <Icon glyph="relaxed" size={16} />,
			perform: () =>
				(window.location.href = adminUrls["The Event Helper"]),
		},
		{
			id: "admin_tool_29",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "Google Workspace Waitlist",
			icon: <Icon glyph="google" size={16} />,
			perform: () =>
				(window.location.href = adminUrls["Google Workspace Waitlist"]),
		},
		{
			id: "admin_tool_30",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "Bank Fees",
			icon: <Icon glyph="bank-circle" size={16} />,
			perform: () => (window.location.pathname = "/admin/bank_fees"),
		},
		{
			id: "admin_tool_30",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "Organization Balances",
			icon: <Icon glyph="payment" size={16} />,
			perform: () => (window.location.pathname = "/admin/balances"),
		},
		{
			id: "admin_tool_31",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "Check Deposits",
			icon: <Icon glyph="payment-docs" size={16} />,
			perform: () => (window.location.pathname = "/admin/check_deposits"),
		},
		{
			id: "admin_tool_32",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "Blazer",
			icon: <Icon glyph="bolt" size={16} />,
			perform: () => (window.location.pathname = "/blazer"),
		},
		{
			id: "admin_tool_33",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "Common Documents",
			icon: <Icon glyph="docs" size={16} />,
			perform: () => (window.location.pathname = "/documents"),
		},
		{
			id: "admin_tool_34",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "Pending Ledger",
			icon: <Icon glyph="list" size={16} />,
			perform: () => (window.location.pathname = "/admin/pending_ledger"),
		},
		{
			id: "admin_tool_35",
			section: "Admin Tools",
			priority: Priority.HIGH,
			name: "Recurring Donations",
			icon: <Icon glyph="transactions" size={16} />,
			perform: () => (window.location.pathname = "/admin/recurring_donations"),
		},
	];

	return (
		<div style={{ position: "relative", zIndex: "1000" }}>
			<KBarProvider actions={[...initalActions, ...(admin ? adminToolsCards : [])]}>
				<KBarPortal>
					<KBarPositioner style={{ zIndex: 1000 }}>
						<KBarAnimator style={animatorStyle}>
							<KBarSearch style={searchStyle} />
							<RenderResults />
						</KBarAnimator>
					</KBarPositioner>
				</KBarPortal>
				<ActionRegister />
			</KBarProvider>
		</div>
	);
}

function RenderResults() {
	const { results, rootActionId } = useMatches();

	return (
		<KBarResults
			items={results}
			onRender={({ item, active }) =>
				typeof item === "string" ? (
					<div style={groupNameStyle}>{item}</div>
				) : (
					<ResultItem
						action={item}
						active={active}
						currentRootActionId={rootActionId}
					/>
				)
			}
		/>
	);
}

const ResultItem = React.forwardRef(
	({ action, active, currentRootActionId }, ref) => {
		const ancestors = React.useMemo(() => {
			if (!currentRootActionId) return action.ancestors;
			const index = action.ancestors.findIndex(
				(ancestor) => ancestor.id === currentRootActionId,
			);
			return action.ancestors.slice(index + 1);
		}, [action.ancestors, currentRootActionId]);

		return (
			<div
				ref={ref}
				style={{
					padding: "12px 16px",
					background: active ? "var(--kbar-overlay)" : "transparent",
					borderLeft: `2px solid ${active ? "var(--kbar-foreground)" : "transparent"}`,
					display: "flex",
					alignItems: "center",
					justifyContent: "space-between",
					cursor: "pointer",
				}}
			>
				<div
					style={{
						display: "flex",
						gap: "8px",
						alignItems: "center",
						fontSize: 14,
					}}
				>
					{action.icon && action.icon}
					<div style={{ display: "flex", flexDirection: "column" }}>
						<div>
							{ancestors.length > 0 &&
								ancestors.map((ancestor) => (
									<React.Fragment key={ancestor.id}>
										<span
											style={{
												opacity: 0.5,
												marginRight: 8,
											}}
										>
											{ancestor.name}
										</span>
										<span
											style={{
												marginRight: 8,
											}}
										>
											&rsaquo;
										</span>
									</React.Fragment>
								))}
							<span>{action.name}</span>
						</div>
						{action.subtitle && (
							<span style={{ fontSize: 12 }}>{action.subtitle}</span>
						)}
					</div>
				</div>
				{action.shortcut?.length ? (
					<div
						aria-hidden
						style={{ display: "grid", gridAutoFlow: "column", gap: "4px" }}
					>
						{action.shortcut.map((sc) => (
							<kbd
								key={sc}
								style={{
									padding: "4px 6px",
									background: "rgba(0 0 0 / .1)",
									borderRadius: "4px",
									fontSize: 14,
								}}
							>
								{sc}
							</kbd>
						))}
					</div>
				) : null}
			</div>
		);
	},
);

ResultItem.displayName = "ResultItem"
