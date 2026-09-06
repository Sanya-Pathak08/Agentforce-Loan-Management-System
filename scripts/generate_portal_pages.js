const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const basePath = 'force-app/main/default/digitalExperiences/site/Loan_Engagement_Portal1';

function createPageView(title, urlName, viewType, componentDef) {
  const rootId = crypto.randomUUID();
  const contentRegionId = crypto.randomUUID();
  const sectionId = crypto.randomUUID();
  const colId = crypto.randomUUID();
  const compId = crypto.randomUUID();
  const hiddenRegionId = crypto.randomUUID();
  const seoId = crypto.randomUUID();

  const sectionConfig = JSON.stringify({
    UUID: sectionId,
    columns: [
      {
        UUID: colId,
        columnName: 'Column 1',
        columnKey: 'col1',
        columnWidth: '12',
        seedComponents: null
      }
    ]
  });

  return {
    type: 'sfdc_cms__view',
    title: title,
    contentBody: {
      component: {
        children: [
          {
            children: [
              {
                attributes: {
                  backgroundImageConfig: '',
                  backgroundImageOverlay: 'rgba(0,0,0,0)',
                  componentSpacerSize: '',
                  layoutDirectionDesktop: 'row',
                  layoutDirectionMobile: 'column',
                  layoutDirectionTablet: 'column',
                  maxContentWidth: '',
                  sectionColumnGutterWidth: '',
                  sectionConfig: sectionConfig,
                  sectionMinHeight: '',
                  sectionVerticalAlign: 'flex-start'
                },
                children: [
                  {
                    children: [
                      {
                        attributes: {},
                        definition: componentDef,
                        id: compId,
                        type: 'component'
                      }
                    ],
                    id: colId,
                    name: 'col1',
                    title: 'Column 1',
                    type: 'region'
                  }
                ],
                definition: 'community_layout:section',
                id: sectionId,
                type: 'component'
              }
            ],
            id: contentRegionId,
            name: 'content',
            title: 'Content',
            type: 'region'
          },
          {
            children: [
              {
                attributes: {
                  customHeadTags: '',
                  description: '',
                  pageTitle: title,
                  recordId: '{!recordId}'
                },
                definition: 'community_builder:seoAssistant',
                id: seoId,
                type: 'component'
              }
            ],
            id: hiddenRegionId,
            name: 'sfdcHiddenRegion',
            title: 'sfdcHiddenRegion',
            type: 'region'
          }
        ],
        definition: 'community_layout:sldsFlexibleLayout',
        id: rootId,
        type: 'component'
      },
      dataProviders: [],
      themeLayoutType: 'Inner',
      viewType: viewType
    },
    urlName: urlName
  };
}

function writeRouteAndView(routeApiName, viewApiName, title, urlName, viewType, componentDef, pageAccess) {
  const viewDir = path.join(basePath, 'sfdc_cms__view', viewApiName);
  const routeDir = path.join(basePath, 'sfdc_cms__route', routeApiName);

  fs.mkdirSync(viewDir, { recursive: true });
  fs.mkdirSync(routeDir, { recursive: true });

  const viewContent = createPageView(title, urlName, viewType, componentDef);

  fs.writeFileSync(path.join(viewDir, '_meta.json'), JSON.stringify({
    apiName: viewApiName,
    type: 'sfdc_cms__view',
    path: 'views'
  }, null, 2));
  fs.writeFileSync(path.join(viewDir, 'content.json'), JSON.stringify(viewContent, null, 2));

  fs.writeFileSync(path.join(routeDir, '_meta.json'), JSON.stringify({
    apiName: routeApiName,
    type: 'sfdc_cms__route',
    path: 'routes'
  }, null, 2));
  fs.writeFileSync(path.join(routeDir, 'content.json'), JSON.stringify({
    type: 'sfdc_cms__route',
    title: title,
    contentBody: {
      activeViewId: viewApiName,
      configurationTags: [],
      pageAccess: pageAccess,
      routeType: viewType,
      urlPrefix: urlName
    },
    urlName: urlName
  }, null, 2));

  console.log('Created Route ' + routeApiName + ' and View ' + viewApiName + ' (' + urlName + ')');
}

const pages = [
  {
    routeApiName: 'Loan_Application__c',
    viewApiName: 'loanApplication',
    title: 'Apply for a Loan',
    urlName: 'loan-application',
    viewType: 'custom-loan-application',
    componentDef: 'c:loanApplicationIntake',
    pageAccess: 'UseParent'
  },
  {
    routeApiName: 'Loan_Account_Dashboard__c',
    viewApiName: 'loanAccountDashboard',
    title: 'My Loan Dashboard',
    urlName: 'loan-account',
    viewType: 'custom-loan-account',
    componentDef: 'c:loanAccountDashboard',
    pageAccess: 'RequiresLogin'
  },
  {
    routeApiName: 'EMI_Tracker__c',
    viewApiName: 'emiTracker',
    title: 'EMI Tracker',
    urlName: 'emi-tracker',
    viewType: 'custom-emi-tracker',
    componentDef: 'c:emiTracker',
    pageAccess: 'RequiresLogin'
  },
  {
    routeApiName: 'Loan_FAQ__c',
    viewApiName: 'loanFaq',
    title: 'Loan Policies and FAQs',
    urlName: 'loan-faq',
    viewType: 'custom-loan-faq',
    componentDef: 'c:loanPolicyFaq',
    pageAccess: 'UseParent'
  }
];

for (const p of pages) {
  writeRouteAndView(p.routeApiName, p.viewApiName, p.title, p.urlName, p.viewType, p.componentDef, p.pageAccess);
}

// Update Scoped Header and Footer
const themePath = path.join(basePath, 'sfdc_cms__themeLayout/scopedHeaderAndFooter/content.json');
const themeLayout = JSON.parse(fs.readFileSync(themePath, 'utf8'));

const headerHtml = `
<div style="background-color: #1B3A6B; padding: 14px 28px; box-shadow: 0 2px 8px rgba(0,0,0,0.15); display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap;">
  <div style="display: flex; align-items: center; gap: 12px;">
    <div style="background: #FFFFFF; color: #1B3A6B; font-weight: 800; font-size: 18px; padding: 6px 12px; border-radius: 6px; letter-spacing: 0.5px;">APEX</div>
    <div>
      <div style="color: #FFFFFF; font-size: 16px; font-weight: 700; line-height: 1.2;">Apex Capital</div>
      <div style="color: #90CAF9; font-size: 11px; font-weight: 500; letter-spacing: 0.5px;">LOAN ENGAGEMENT PORTAL</div>
    </div>
  </div>
  <nav style="display: flex; gap: 8px; align-items: center; flex-wrap: wrap;">
    <a href="./" style="color: #FFFFFF; text-decoration: none; padding: 8px 14px; font-size: 13px; font-weight: 600; border-radius: 4px; transition: background 0.2s;">Home</a>
    <a href="./loan-application" style="color: #FFFFFF; text-decoration: none; padding: 8px 14px; font-size: 13px; font-weight: 600; border-radius: 4px;">Apply for Loan</a>
    <a href="./loan-account" style="color: #FFFFFF; text-decoration: none; padding: 8px 14px; font-size: 13px; font-weight: 600; border-radius: 4px;">My Dashboard</a>
    <a href="./emi-tracker" style="color: #FFFFFF; text-decoration: none; padding: 8px 14px; font-size: 13px; font-weight: 600; border-radius: 4px;">EMI Tracker</a>
    <a href="./loan-faq" style="color: #FFFFFF; text-decoration: none; padding: 8px 14px; font-size: 13px; font-weight: 600; border-radius: 4px;">Policies & FAQs</a>
  </nav>
</div>
`.trim();

const footerHtml = `
<div style="background-color: #0d1e38; color: #90CAF9; padding: 24px; text-align: center; font-size: 12px; margin-top: 40px; border-top: 1px solid rgba(255,255,255,0.1);">
  <div style="max-width: 800px; margin: 0 auto; line-height: 1.6;">
    <strong style="color: #FFFFFF;">Apex Capital — Autonomous Lending & Loan Engagement Services</strong><br/>
    Protected by Enterprise Security, Agentforce Headless 360 AI Guardrails, and strict Guest Privacy Controls.<br/>
    &copy; 2026 Apex Capital Financial Services Ltd. All rights reserved.
  </div>
</div>
`.trim();

// Insert header component
const headerSec = themeLayout.contentBody.component.children[0].children[0].children[0];
headerSec.children = [{
  attributes: {
    richTextValue: headerHtml
  },
  definition: 'community_builder:htmlEditor',
  id: crypto.randomUUID(),
  type: 'component'
}];

// Insert footer component
const footerSec = themeLayout.contentBody.component.children[1].children[0].children[0];
footerSec.children = [{
  attributes: {
    richTextValue: footerHtml
  },
  definition: 'community_builder:htmlEditor',
  id: crypto.randomUUID(),
  type: 'component'
}];

fs.writeFileSync(themePath, JSON.stringify(themeLayout, null, 2));
console.log('Updated scopedHeaderAndFooter with styled navigation header and footer');

// Update Home page with welcome hub & quick action cards
const homePath = path.join(basePath, 'sfdc_cms__view/home/content.json');
const homeView = JSON.parse(fs.readFileSync(homePath, 'utf8'));

const homeHeroHtml = `
<div style="max-width: 1100px; margin: 24px auto 32px; padding: 0 16px;">
  <div style="background: linear-gradient(135deg, #1B3A6B 0%, #2A5298 100%); border-radius: 12px; padding: 36px 32px; color: #FFFFFF; text-align: center; box-shadow: 0 4px 16px rgba(0,0,0,0.12); margin-bottom: 32px;">
    <h1 style="font-size: 32px; font-weight: 800; margin-bottom: 12px; letter-spacing: -0.5px;">Welcome to Apex Capital Loan Portal</h1>
    <p style="font-size: 16px; color: #E3F2FD; max-width: 720px; margin: 0 auto 20px; line-height: 1.5;">
      Fast, transparent, and AI-powered self-service lending. Apply for financing, track active disbursements, manage schedules, and get instant answers from our Agentforce Loan Advisor.
    </p>
    <div style="display: flex; gap: 14px; justify-content: center; flex-wrap: wrap;">
      <a href="./loan-application" style="background: #FFFFFF; color: #1B3A6B; padding: 12px 24px; border-radius: 6px; font-weight: 700; text-decoration: none; font-size: 14px; box-shadow: 0 2px 6px rgba(0,0,0,0.15);">Apply for a Loan &rarr;</a>
      <a href="./loan-account" style="background: rgba(255,255,255,0.15); border: 1px solid rgba(255,255,255,0.4); color: #FFFFFF; padding: 12px 24px; border-radius: 6px; font-weight: 600; text-decoration: none; font-size: 14px;">View My Dashboard</a>
    </div>
  </div>

  <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 20px; margin-bottom: 36px;">
    <div style="background: #FFFFFF; border: 1px solid #E0E0E0; border-radius: 10px; padding: 24px; box-shadow: 0 2px 6px rgba(0,0,0,0.04); text-align: center;">
      <div style="font-size: 28px; margin-bottom: 8px;">📝</div>
      <h3 style="font-size: 18px; font-weight: 700; color: #1B3A6B; margin-bottom: 8px;">Loan Application</h3>
      <p style="font-size: 13px; color: #666; margin-bottom: 16px; min-height: 38px;">Apply for Home, Personal, or Auto loans in minutes with instant automated assessment.</p>
      <a href="./loan-application" style="display: inline-block; background: #1B3A6B; color: #FFFFFF; padding: 8px 18px; border-radius: 4px; font-size: 12px; font-weight: 600; text-decoration: none;">Start Application</a>
    </div>

    <div style="background: #FFFFFF; border: 1px solid #E0E0E0; border-radius: 10px; padding: 24px; box-shadow: 0 2px 6px rgba(0,0,0,0.04); text-align: center;">
      <div style="font-size: 28px; margin-bottom: 8px;">📊</div>
      <h3 style="font-size: 18px; font-weight: 700; color: #1B3A6B; margin-bottom: 8px;">Account Dashboard</h3>
      <p style="font-size: 13px; color: #666; margin-bottom: 16px; min-height: 38px;">Track loan balances, repayment status, overdue alerts, and borrower statistics.</p>
      <a href="./loan-account" style="display: inline-block; background: #1B3A6B; color: #FFFFFF; padding: 8px 18px; border-radius: 4px; font-size: 12px; font-weight: 600; text-decoration: none;">View Accounts</a>
    </div>

    <div style="background: #FFFFFF; border: 1px solid #E0E0E0; border-radius: 10px; padding: 24px; box-shadow: 0 2px 6px rgba(0,0,0,0.04); text-align: center;">
      <div style="font-size: 28px; margin-bottom: 8px;">📅</div>
      <h3 style="font-size: 18px; font-weight: 700; color: #1B3A6B; margin-bottom: 8px;">EMI Tracker</h3>
      <p style="font-size: 13px; color: #666; margin-bottom: 16px; min-height: 38px;">Monitor upcoming payments, filter installments, and generate official statements.</p>
      <a href="./emi-tracker" style="display: inline-block; background: #1B3A6B; color: #FFFFFF; padding: 8px 18px; border-radius: 4px; font-size: 12px; font-weight: 600; text-decoration: none;">Track EMIs</a>
    </div>

    <div style="background: #FFFFFF; border: 1px solid #E0E0E0; border-radius: 10px; padding: 24px; box-shadow: 0 2px 6px rgba(0,0,0,0.04); text-align: center;">
      <div style="font-size: 28px; margin-bottom: 8px;">💬</div>
      <h3 style="font-size: 18px; font-weight: 700; color: #1B3A6B; margin-bottom: 8px;">Policies & FAQs</h3>
      <p style="font-size: 13px; color: #666; margin-bottom: 16px; min-height: 38px;">Browse interest rates, tenure policies, hardship options, and chat with AI advisor.</p>
      <a href="./loan-faq" style="display: inline-block; background: #1B3A6B; color: #FFFFFF; padding: 8px 18px; border-radius: 4px; font-size: 12px; font-weight: 600; text-decoration: none;">Explore FAQs</a>
    </div>
  </div>
</div>
`.trim();

const homeContentRegion = homeView.contentBody.component.children[0];
homeContentRegion.children = [homeContentRegion.children[0]];
// Set Section 1 to home hero
const section1Col = homeContentRegion.children[0].children[0];
section1Col.children = [{
  attributes: {
    richTextValue: homeHeroHtml
  },
  definition: 'community_builder:htmlEditor',
  id: crypto.randomUUID(),
  type: 'component'
}];

// Add Section 2 with c:loanPolicyFaq right on the Home page
const sec2Id = crypto.randomUUID();
const sec2ColId = crypto.randomUUID();
const sec2CompId = crypto.randomUUID();

const sec2Config = JSON.stringify({
  UUID: sec2Id,
  columns: [
    {
      UUID: sec2ColId,
      columnName: 'Column 1',
      columnKey: 'col1',
      columnWidth: '12',
      seedComponents: null
    }
  ]
});

homeContentRegion.children.push({
  attributes: {
    backgroundImageConfig: '',
    backgroundImageOverlay: 'rgba(0,0,0,0)',
    componentSpacerSize: '',
    layoutDirectionDesktop: 'row',
    layoutDirectionMobile: 'column',
    layoutDirectionTablet: 'column',
    maxContentWidth: '',
    sectionColumnGutterWidth: '',
    sectionConfig: sec2Config,
    sectionMinHeight: '',
    sectionVerticalAlign: 'flex-start'
  },
  children: [
    {
      children: [
        {
          attributes: {},
          definition: 'c:loanPolicyFaq',
          id: sec2CompId,
          type: 'component'
        }
      ],
      id: sec2ColId,
      name: 'col1',
      title: 'Column 1',
      type: 'region'
    }
  ],
  definition: 'community_layout:section',
  id: sec2Id,
  type: 'component'
});

fs.writeFileSync(homePath, JSON.stringify(homeView, null, 2));
console.log('Updated home page with Hero Dashboard and c:loanPolicyFaq component');
